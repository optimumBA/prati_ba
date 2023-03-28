defmodule PratiBa.Scrapers.RaskrinkavanjeScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://raskrinkavanje.ba/analize"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status: 200, body: body}} <- response,
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

  def article_details(article), do: {:ok, article}

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

    image_style =
      article
      |> Floki.find(".image")
      |> Floki.attribute("style")
      |> Enum.at(0)

    image_url =
      case Regex.named_captures(~r/url\('(?<url>[^']+)'\);/, image_style) do
        %{"url" => image_url} ->
          URI.encode(image_url)

        _ ->
          nil
      end

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: published_at,
      author: nil,
      image: image_url,
      url: url
    }
  end
end
