defmodule PratiBa.Scrapers.PrvaSmjenaScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "http://prvasmjena.com/feed/"

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
      image_url =
        html
        |> Floki.find(".entry-thumbnail img")
        |> Floki.attribute("src")
        |> Enum.at(0)
        |> URI.encode()

      {:ok, Map.put(article, :image, image_url)}
    else
      _ -> {:ok, Map.put(article, :image, nil)}
    end
  end

  defp parse_article(article) do
    %{
      "description" => description,
      "link" => url,
      "guid" => %{
        "value" => "http://prvasmjena.com/?p=" <> original_id
      },
      "pub_date" => date,
      "title" => title
    } = article

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    %{
      original_id: original_id,
      title: title,
      description: description,
      published_at: published_at,
      author: nil,
      image: nil,
      url: URI.encode(url)
    }
  end
end
