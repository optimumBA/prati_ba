defmodule PratiBa.Scrapers.N1Scraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url_base "https://ba.n1info.com"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url_base \\ @url_base) do
    response = ScrapingHelper.get(url_base <> "/wp-json/wp/v2/posts/")

    with {:ok, %{status_code: 200, body: body}} <- response,
         body <- HtmlEntities.decode(body),
         {:ok, articles} <- Jason.decode(body) do
      articles =
        articles
        |> Stream.map(&parse_article(&1, url_base))

      {:ok, articles}
    else
      {_, response} -> {:error, response}
    end
  end

  def article_details(%{image: image_url} = article) when is_binary(image_url) do
    response = ScrapingHelper.get(image_url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, media} <- Jason.decode(body),
         %{"media_details" => %{"sizes" => %{"full" => %{"source_url" => image_url}}}} <- media do
      image_url = URI.encode(image_url)
      {:ok, Map.put(article, :image, image_url)}
    else
      _ -> {:error, :article_not_available}
    end
  end

  def article_details(article), do: {:ok, article}

  defp should_scrape(%{link: "http://ba.n1info.com/english/" <> _}), do: false
  defp should_scrape(_), do: true

  defp parse_article(article, url_base) do
    %{
      "id" => original_id,
      "date_gmt" => published_at,
      "link" => url,
      "title" => %{
        "rendered" => title
      },
      "featured_image" => image
    } = article

    title =
      title
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    %{
      original_id: Integer.to_string(original_id),
      title: HtmlSanitizeEx.strip_tags(title),
      description: nil,
      published_at: Timex.parse!(published_at, "{RFC3339}"),
      author: nil,
      image: image,
      url: URI.encode(url)
    }
  end
end
