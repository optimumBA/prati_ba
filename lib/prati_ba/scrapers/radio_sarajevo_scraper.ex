defmodule PratiBa.Scrapers.RadioSarajevoScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://radiosarajevo.ba/rss"

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, feed, _} =
          body
          |> HtmlEntities.decode()
          |> String.trim()
          |> FeederEx.parse()

        articles =
          feed.entries
          |> Stream.map(&parse_article/1)

        {:ok, articles}

      {_, response} ->
        {:error, response}
    end
  end

  def article_details(article), do: {:ok, article}

  defp parse_article(article) do
    %FeederEx.Entry{
      author: author,
      link: url,
      summary: summary,
      title: title,
      updated: date
    } = article

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)

    published_at =
      date
      |> Timex.parse!("{RFC3339}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    image =
      case Regex.named_captures(~r/src="(?<url>[^"]+)"/, summary) do
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
      author: author,
      image: image,
      url: URI.encode(url)
    }
  end
end
