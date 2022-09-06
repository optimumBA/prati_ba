defmodule PratiBa.Scrapers.CapitalBaScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://www.capital.ba/"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".horisontal-news")
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_, response} -> {:error, response}
    end
  end

  defp parse_article(article) do
    url =
      article
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.at(0)

    title =
      article
      |> Floki.find(".cat-description h2")
      |> Floki.text()

    %{
      original_id: nil,
      title: title,
      description: nil,
      published_at: nil,
      author: nil,
      image: nil,
      url: url
    }
  end

  def article_details(%{url: url} = article) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      article_container =
        html
        |> Floki.find(".container-fluid .row .col-lg-12")

      date =
        article_container
        |> Floki.find("p")
        |> Enum.at(0)
        |> Floki.text()
        |> String.trim()

      published_at =
        date
        |> Timex.parse!("{D}.{M}.{YYYY}. / {_h24}:{m}")
        |> DateTime.from_naive!("Europe/Sarajevo")
        |> DateTime.shift_zone!("Etc/UTC")
        |> DateTime.to_naive()

      article = Map.put(article, :published_at, published_at)

      article =
        case ScrapingHelper.get_og_description(html) do
          {:ok, description} -> Map.put(article, :description, description)
          _ -> article
        end

      case ScrapingHelper.get_og_image(html) do
        {:ok, image_url} ->
          {:ok, Map.put(article, :image_url, image_url)}

        _ ->
          article
      end
    else
      _ -> {:error, :article_not_available}
    end
  end
end
