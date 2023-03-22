defmodule PratiBa.Scrapers.FrontalScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.frontal.ba/rss"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status: 200, body: body}} ->
        {:ok, rss} =
          body
          |> HtmlEntities.decode()
          |> FastRSS.parse()

        articles = Stream.map(rss["items"], &parse_article/1)

        {:ok, articles}

      {_, response} ->
        {:error, response}
    end
  end

  def article_details(article), do: {:ok, article}

  defp parse_article(article) do
    %{
      "guid" => %{
        "value" => url
      },
      "pub_date" => date,
      "title" => title,
      "description" => description,
      "enclosure" => %{
        "url" => image_url
      }
    } = article

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(4)

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    %{
      original_id: original_id,
      title: title,
      description: description,
      published_at: published_at,
      author: nil,
      image: image_url,
      url: URI.encode(url)
    }
  end
end
