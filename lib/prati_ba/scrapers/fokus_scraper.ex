defmodule PratiBa.Scrapers.FokusScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.fokus.ba/feed/"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, rss} =
          body
          |> HtmlEntities.decode()
          |> FastRSS.parse()

        articles =
          rss["items"]
          |> Stream.map(&parse_article/1)

        {:ok, articles}

      {_, response} ->
        {:error, response}
    end
  end

  def article_details(%{url: url} = article) do
    response = Mojito.request(method: :get, url: url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      image_url = ScrapingHelper.get_og_image(html)

      {:ok, Map.put(article, :image, image_url)}
    else
      _ -> {:ok, article}
    end
  end

  defp parse_article(article) do
    %{
      "guid" => %{
        "value" => "https://www.fokus.ba/?p=" <> original_id
      },
      "link" => url,
      "pub_date" => date,
      "title" => title
    } = article

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.to_naive()

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: published_at,
      author: nil,
      image: nil,
      url: URI.encode(url)
    }
  end
end
