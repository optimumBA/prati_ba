defmodule PratiBa.Scrapers.BljesakScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://www.bljesak.info/najnovije"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find("article")
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
      article_container =
        html
        |> Floki.find("#article-content")

      article =
        case ScrapingHelper.get_og_description(html) do
          {:ok, description} -> Map.put(article, :description, description)
          _ -> article
        end

      date =
        article_container
        |> Floki.find(".info span")
        |> Enum.reverse()
        |> get_date()
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
    link =
      article
      |> Floki.find(".title a")

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

  defp get_date([head | tail]) do
    text = Floki.text(head)

    if text =~ ~r/\d{2}\. \d{2}\. \d{4}\. u \d{2}:\d{2}/ do
      text
    else
      get_date(tail)
    end
  end
end
