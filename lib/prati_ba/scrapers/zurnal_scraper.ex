defmodule PratiBa.Scrapers.ZurnalScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @url "https://zurnal.info/najnovije"

  @impl Scraper
  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".left .articles a")
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_other, response} -> {:error, response}
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
      |> List.last()

    title =
      article
      |> Floki.find(".title")
      |> Floki.text()

    description =
      article
      |> Floki.find(".description")
      |> Enum.at(0)
      |> Floki.text()
      |> String.trim()

    %{
      original_id: original_id,
      title: title,
      description: description,
      published_at: nil,
      author: nil,
      image: nil,
      url: "https://zurnal.info" <> URI.encode(url)
    }
  end

  @impl Scraper
  def article_details(%{url: url} = article) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      article_content = Floki.find(html, ".container")

      date =
        article_content
        |> Floki.find(".article-info, time")
        |> Floki.attribute("datetime")
        |> Enum.at(0)

      published_at =
        date
        |> Timex.parse!("{YYYY}-{M}-{D} {h24}:{m}:{s}")
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
end
