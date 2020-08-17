defmodule PratiBa.Scrapers.N1Scraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://ba.n1info.com/rss/249/Naslovna"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, feed, _} =
          body
          |> String.trim()
          |> FeederEx.parse()

        articles =
          feed.entries
          |> Stream.filter(&should_scrape/1)
          |> Stream.map(&parse_article/1)

        {:ok, articles}

      {_, response} ->
        {:error, response}
    end
  end

  def article_details(article), do: {:ok, article}

  defp should_scrape(%{link: "http://ba.n1info.com/English/" <> _}), do: false
  defp should_scrape(_), do: true

  defp parse_article(article) do
    %FeederEx.Entry{
      image: image_url,
      link: url,
      summary: description,
      title: title,
      updated: date
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

    image_url =
      case image_url do
        nil ->
          nil

        image_url ->
          URI.encode(image_url)
      end

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
