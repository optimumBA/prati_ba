defmodule PratiBa.Scrapers.RaskrinkavanjeScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://raskrinkavanje.ba/analize"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".card")
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_, response} -> {:error, response}
    end
  end

  def article_details(%{url: url} = article) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body),
         {:ok, image_url} <- ScrapingHelper.get_og_image(html) do
      {:ok, Map.put(article, :image, image_url)}
    else
      _ -> {:error, :article_not_available}
    end
  end

  defp parse_article(article) do
    link =
      article
      |> Floki.find(".card-body a")

    url =
      link
      |> Floki.attribute("href")
      |> Enum.at(0)
      |> URI.encode()

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)

    title =
      link
      |> Floki.text()
      |> String.trim()

    published_at =
      article
      |> Floki.find(".card-footer .float-left")
      |> Floki.text()
      |> String.trim()
      |> Timex.parse!("{D}.{M}.{YYYY}")

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: published_at,
      author: nil,
      image: nil,
      url: url
    }
  end
end
