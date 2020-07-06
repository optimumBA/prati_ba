defmodule PratiBa.Scrapers.OslobodjenjeScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.oslobodjenje.ba/feed"

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, rss} = FastRSS.parse(body)

        articles = rss["items"]
        |> Stream.filter(&should_scrape/1)
        |> Stream.map(&parse_article/1)

        {:ok, articles}
      {_, response} ->
        {:error, response}
    end
  end

  defp should_scrape(%{"categories" => [%{"name" => "Izjava dana"}]}), do: false
  defp should_scrape(%{"categories" => [%{"name" => "Smrtovnice"}]}), do: false
  defp should_scrape(_), do: true

  defp parse_article(article) do
    %{
      "enclosure" => %{
        "url" => image_url,
      },
      "link" => url,
      "pub_date" => date,
      "title" => title,
    } = article

    original_id = url
    |> String.split("/")
    |> Enum.fetch!(5)
    |> String.split("-")
    |> Enum.fetch!(-1)

    published_at = date
    |> Timex.parse!("{RFC1123}")
    |> DateTime.shift_zone!("Etc/UTC")
    |> DateTime.to_naive()

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: published_at,
      author: nil,
      image: image_url,
      url: URI.encode(url),
    }
  end
end
