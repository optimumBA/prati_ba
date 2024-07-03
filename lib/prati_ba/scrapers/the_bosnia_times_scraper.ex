defmodule PratiBa.Scrapers.TheBosniaTimesScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @url_base "https://thebosniatimes.ba"

  @impl Scraper
  def articles(url_base \\ @url_base) do
    response = ScrapingHelper.get(url_base <> "/wp-json/wp/v2/posts/")

    with {:ok, %{status: 200, body: body}} <- response,
         {:ok, articles} <- Jason.decode(body) do
      articles = Stream.map(articles, &parse_article(&1, url_base))

      {:ok, articles}
    else
      {_other, response} -> {:error, response}
    end
  end

  @impl Scraper
  def article_details(%{image: image_url} = article) when is_binary(image_url) do
    response = ScrapingHelper.get(image_url)

    with {:ok, %{status: 200, body: body}} <- response,
         {:ok, media} <- Jason.decode(body),
         %{"media_details" => %{"sizes" => %{"full" => %{"source_url" => image_url}}}} <- media do
      image_url = URI.encode(image_url)
      {:ok, Map.put(article, :image, image_url)}
    else
      _other -> {:error, :article_not_available}
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

    title_2 =
      title
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    description_2 =
      description
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    %{
      original_id: Integer.to_string(original_id),
      title: HtmlSanitizeEx.strip_tags(title_2),
      description: HtmlSanitizeEx.strip_tags(description_2),
      published_at: Timex.parse!(published_at, "{RFC3339}"),
      author: nil,
      image: "#{url_base}/wp-json/wp/v2/media/#{image_id}",
      url: URI.encode(url)
    }
  end
end
