defmodule PratiBa.Scrapers.StartBihScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @url "https://startbih.ba/"

  @impl Scraper
  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".col-lg-8 .row .mb-30")
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_other, response} -> {:error, response}
    end
  end

  @impl Scraper
  def article_details(%{url: url} = article) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      article_content = Floki.find(html, ".row .mb-30")

      article =
        case ScrapingHelper.get_og_description(html) do
          {:ok, description} -> Map.put(article, :description, description)
          _other -> article
        end

      date =
        article_content
        |> Floki.find(".news-details-layout1 ul li")
        |> Floki.attribute("title")
        |> Enum.at(0)

      published_at =
        date
        |> Timex.parse!("{D}.{M}.{YYYY} u {h24}:{m}")
        |> DateTime.from_naive!("Europe/Sarajevo")
        |> DateTime.shift_zone!("Etc/UTC")
        |> DateTime.to_naive()

      article = Map.put(article, :published_at, published_at)

      case ScrapingHelper.get_og_image(html) do
        {:ok, image_url} ->
          {:ok, Map.put(article, :image, image_url)}

        {:error, _other} ->
          {:error, :image_not_available}
      end
    else
      _other -> {:error, :article_not_available}
    end
  end

  defp parse_article(article) do
    path = Floki.find(article, "a")

    url =
      path
      |> Floki.attribute("href")
      |> Enum.at(0)

    original_id =
      url
      |> String.split("/")
      |> List.last()

    title =
      article
      |> Floki.find("h3")
      |> Enum.at(0)
      |> Floki.text()
      |> String.trim()

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: nil,
      author: nil,
      image: nil,
      url: URI.encode(url)
    }
  end
end
