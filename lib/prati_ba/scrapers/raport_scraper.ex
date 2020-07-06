defmodule PratiBa.Scrapers.RaportScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url_base "https://raport.ba"

  def articles(url_base \\ @url_base) do
    response = Mojito.request(method: :get, url: url_base <> "/wp-json/wp/v2/posts/")

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
    response = Mojito.request(method: :get, url: image_url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, media} <- Jason.decode(body),
         %{"media_details" => %{"sizes" => %{"full" => %{"source_url" => image_url}}}} <- media do
      image_url = URI.encode(image_url)
      {:ok, Map.put(article, :image, image_url)}
    else
      _ -> {:ok, Map.put(article, :image, nil)}
    end
  end

  def article_details(article), do: {:ok, article}

  defp parse_article(article, url_base) do
    %{
      "id" => original_id,
      "date_gmt" => published_at,
      "link" => url,
      "title" => %{
        "rendered" => title
      },
      "excerpt" => %{
        "rendered" => description
      },
      "featured_media" => image_id
    } = article

    title =
      title
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    description =
      description
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    %{
      original_id: Integer.to_string(original_id),
      title: HtmlSanitizeEx.strip_tags(title),
      description: HtmlSanitizeEx.strip_tags(description),
      published_at: Timex.parse!(published_at, "{RFC3339}"),
      author: nil,
      image: "#{url_base}/wp-json/wp/v2/media/#{image_id}",
      url: URI.encode(url)
    }
  end
end
