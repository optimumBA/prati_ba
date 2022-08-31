defmodule PratiBa.Scrapers.StartBihScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://startbih.ba/"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".row .mb-30 ul li h3 a")
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
      article_content =
        html
        |> Floki.find(".row .mb-30")

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

      case ScrapingHelper.get_og_description(html) do
        {:ok, description} ->
          {:ok, Map.put(article, :description, description)}

        {:error, _} ->
          {:error, :not_available}
      end

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
      |> Enum.fetch!(5)

    title =
      article
      |> Floki.text()
      |> String.trim()

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: nil,
      author: nil,
      image: nil,
      url: url
    }
  end
end
