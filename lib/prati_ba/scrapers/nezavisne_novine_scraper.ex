defmodule PratiBa.Scrapers.NezavisneNovineScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "http://feeds.feedburner.com/NezavisneNovine"

  @impl Scraper
  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status: 200, body: body}} ->
        {:ok, rss} = FastRSS.parse(body)

        articles = Stream.map(rss["items"], &parse_article/1)

        {:ok, articles}

      {_other, response} ->
        {:error, response}
    end
  end

  defp parse_article(article) do
    %{
      "author" => author,
      "description" => description,
      "guid" => %{
        "value" => url
      },
      "pub_date" => date,
      "enclosure" => %{
        "url" => image
      },
      "title" => title
    } = article

    original_id =
      url
      |> String.split("/")
      |> List.last()

    description_2 =
      description
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    published_at =
      date
      |> String.replace("PDT", "GMT-7")
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    %{
      original_id: original_id,
      title: title,
      description: description_2,
      published_at: published_at,
      author: author,
      image: image,
      url: URI.encode(url)
    }
  end

  @spec article_details(map()) :: {:ok, map()}
  def article_details(article), do: {:ok, article}
end
