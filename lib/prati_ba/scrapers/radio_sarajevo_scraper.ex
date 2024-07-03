defmodule PratiBa.Scrapers.RadioSarajevoScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://radiosarajevo.ba/rss"

  @impl Scraper
  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status: 200, body: body}} ->
        {:ok, feed, _other} =
          body
          |> HtmlEntities.decode()
          |> String.trim()
          |> FeederEx.parse()

        articles =
          feed
          |> Map.get(:entries)
          |> Stream.map(&parse_article/1)

        {:ok, articles}

      {_other, response} ->
        {:error, response}
    end
  end

  @spec article_details(map()) :: {:ok, map()}
  def article_details(article), do: {:ok, article}

  defp parse_article(article) do
    %FeederEx.Entry{
      author: author,
      link: url,
      summary: summary,
      title: title,
      updated: date
    } = article

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    image =
      case Regex.named_captures(~r/src="(?<url>[^"]+)"/, summary) do
        %{"url" => image_url} ->
          URI.encode(image_url)

        _other ->
          nil
      end

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: published_at,
      author: author,
      image: image,
      url: URI.encode(url)
    }
  end
end
