defmodule PratiBa.Scrapers.BhDaniScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://bhdani.oslobodjenje.ba/bhdani/"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".row .col-md-7")
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_, response} -> {:error, response}
    end
  end

  def article_details(%{url: url} = article) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      article_container = Floki.find(html, ".container--item")

      article =
        case ScrapingHelper.get_og_description(html) do
          {:ok, description} -> Map.put(article, :description, description)
          _ -> article
        end

      date =
        article_container
        |> Floki.find(".card__category-time span")
        |> Enum.at(0)
        |> Floki.text()
        |> String.trim()

      published_at =
        date
        |> Timex.parse!("{D}/{M}/{YYYY} u {h24}:{m} h")
        |> DateTime.from_naive!("Europe/Sarajevo")
        |> DateTime.shift_zone!("Etc/UTC")
        |> DateTime.to_naive()

      Map.put(article, :published_at, published_at)

      case ScrapingHelper.get_og_image(html) do
        {:ok, image_url} ->
          {:ok, Map.put(article, :image, image_url)}

        {:error, _} ->
          {:error, :image_not_available}
      end
    else
      _ -> {:error, :article_not_available}
    end
  end

  def parse_article(article) do
    url =
      article
      |> Floki.find("a")
      |> Floki.attribute("href")
      |> Enum.at(0)

    path =
      url
      |> String.split("/")
      |> Enum.fetch!(2)

    original_id =
      path
      |> String.split("-")
      |> Enum.at(9)

    title =
      article
      |> Floki.find("a")
      |> Floki.attribute("title")
      |> Enum.at(0)

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: nil,
      author: nil,
      image: nil,
      url: URI.encode("https://bhdani.oslobodjenje.ba/" <> url)
    }
  end
end
