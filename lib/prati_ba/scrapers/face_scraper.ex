defmodule PratiBa.Scrapers.FaceScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://www.face.ba/najnovije"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = Mojito.request(method: :get, url: url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".headline-bottom .article a")
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_, response} -> {:error, response}
    end
  end

  def article_details(%{url: url} = article) do
    response = Mojito.request(method: :get, url: url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      article_container =
        html
        |> Floki.find(".main-article")
        |> Enum.at(-1)

      description =
        article_container
        |> Floki.find(".main-article-small-headline")
        |> Floki.text()
        |> String.trim()

      article =
        case description do
          "" -> article
          description -> Map.put(article, :description, description)
        end

      date =
        article_container
        |> Floki.find(".main-article-info-span")
        |> Enum.at(0)
        |> Floki.text()
        |> String.trim()

      published_at =
        date
        |> Timex.parse!("{D}. {M}. {YYYY}. u {h24}:{m}")
        |> DateTime.from_naive!("Europe/Sarajevo")
        |> DateTime.shift_zone!("Etc/UTC")
        |> DateTime.to_naive()

      article = Map.put(article, :published_at, published_at)

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

  defp parse_article(article) do
    url =
      article
      |> Floki.attribute("href")
      |> Enum.at(0)

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)

    title =
      article
      |> Floki.find(".article-title")
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
