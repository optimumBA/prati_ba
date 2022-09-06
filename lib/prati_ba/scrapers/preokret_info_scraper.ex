defmodule PratiBa.Scrapers.PreokretInfoScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://preokret.info/"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url_base \\ @url) do
    response = ScrapingHelper.get(url_base <> "/wp-json/wp/v2/posts/")

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, articles} <- Jason.decode(body) do
      articles = Stream.map(articles, &parse_article(&1, url_base))

      {:ok, articles}
    else
      {_, response} -> {:error, response}
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
