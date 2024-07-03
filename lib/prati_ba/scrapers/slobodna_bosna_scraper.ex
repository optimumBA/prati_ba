defmodule PratiBa.Scrapers.SlobodnaBosnaScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.slobodna-bosna.ba/rss/100/sve_vijesti.html"

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

  @impl Scraper
  def article_details(%{url: url} = article) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body),
         {:ok, image_url} <- ScrapingHelper.get_og_image(html) do
      {:ok, Map.put(article, :image, image_url)}
    else
      _other -> {:error, :article_not_available}
    end
  end

  defp parse_article(article) do
    %{
      "link" => url,
      "pub_date" => date,
      "title" => title
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
      description: nil,
      published_at: published_at,
      author: nil,
      image: nil,
      url: URI.encode(url)
    }
  end
end
