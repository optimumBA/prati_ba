defmodule PratiBa.Scrapers.DwScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://rss.dw.com/rdf/rss-bos-all"

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
      "description" => description,
      "dublin_core_ext" => %{
        "dates" => [date]
      },
      "extensions" => %{
        "dwsyn" => %{
          "contentID" => [
            %{
              "name" => "dwsyn:contentID",
              "value" => original_id
            }
          ]
        }
      },
      "link" => url,
      "title" => title
    } = article

    published_at =
      date
      |> Timex.parse!("{RFC3339}")
      |> DateTime.to_naive()

    %{
      original_id: original_id,
      title: title,
      description: description,
      published_at: published_at,
      author: nil,
      image: nil,
      url: URI.encode(url)
    }
  end
end
