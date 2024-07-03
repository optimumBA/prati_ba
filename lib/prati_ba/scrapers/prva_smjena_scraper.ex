defmodule PratiBa.Scrapers.PrvaSmjenaScraper do
  @moduledoc false

  alias PratiBa.Scrapers.Scraper
  alias PratiBa.Scrapers.ScrapingHelper

  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://prvasmjena.com/feed/"

  @impl Scraper
  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status: 200, body: body}} ->
        {:ok, rss} =
          body
          |> HtmlEntities.decode()
          |> FastRSS.parse()

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
      "link" => url,
      "guid" => %{
        "value" => "https://prvasmjena.com/?p=" <> original_id
      },
      "pub_date" => date,
      "title" => title
    } = article

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    description_2 = String.trim(description)

    %{
      original_id: original_id,
      title: title,
      description: description_2,
      published_at: published_at,
      author: nil,
      image: nil,
      url: URI.encode(url)
    }
  end
end
