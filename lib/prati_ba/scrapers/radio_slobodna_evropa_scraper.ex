defmodule PratiBa.Scrapers.RadioSlobodnaEvropaScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.slobodnaevropa.org/api/zqtovekoir"

  @impl Scraper
  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status: 200, body: body}} ->
        {:ok, rss} = FastRSS.parse(body)

        articles =
          rss
          |> Map.get("items")
          |> Stream.map(&parse_article/1)

        {:ok, articles}

      {_other, response} ->
        {:error, response}
    end
  end

  @spec article_details(map()) :: {:ok, map()}
  def article_details(article), do: {:ok, article}

  defp parse_article(article) do
    %{
      "author" => author,
      "description" => description,
      "enclosure" => enclosure,
      "link" => url,
      "pub_date" => date,
      "title" => title
    } = article

    maybe_author =
      with false <- is_nil(author),
           %{"author" => author} <- Regex.named_captures(~r/\((?<author>[^\)]+)\)$/, author) do
        author
      else
        _other -> nil
      end

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)
      |> String.split(".")
      |> Enum.fetch!(0)

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    maybe_image_url =
      case enclosure do
        nil ->
          nil

        %{"url" => nil} ->
          nil

        %{"url" => image_url} ->
          URI.encode(image_url)
      end

    %{
      original_id: original_id,
      title: title,
      description: description,
      published_at: published_at,
      author: maybe_author,
      image: maybe_image_url,
      url: url
    }
  end
end
