defmodule PratiBa.Scrapers.OslobodjenjeScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.oslobodjenje.ba/feed"

  @impl Scraper
  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status: 200, body: body}} ->
        {:ok, rss} = FastRSS.parse(body)

        articles =
          rss
          |> Map.get("items")
          |> Stream.filter(&should_scrape/1)
          |> Stream.map(&parse_article/1)

        {:ok, articles}

      {_other, response} ->
        {:error, response}
    end
  end

  @spec article_details(map()) :: {:ok, map()}
  def article_details(article), do: {:ok, article}

  defp should_scrape(%{"categories" => [%{"name" => "Izjava dana"}]}), do: false
  defp should_scrape(%{"categories" => [%{"name" => "Smrtovnice"}]}), do: false
  defp should_scrape(_other), do: true

  defp parse_article(article) do
    %{
      "enclosure" => %{
        "url" => image_url
      },
      "link" => url,
      "pub_date" => date,
      "title" => title
    } = article

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)
      |> String.split("-")
      |> Enum.fetch!(-1)

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: published_at,
      author: nil,
      image: (image_url != nil && URI.encode(image_url)) || nil,
      url: URI.encode(url)
    }
  end
end
