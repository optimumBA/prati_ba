defmodule PratiBa.Scrapers.NezavisneNovineScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "http://feeds.feedburner.com/NezavisneNovine"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, rss} = FastRSS.parse(body)

        articles =
          rss["items"]
          |> Stream.map(&parse_article/1)

        {:ok, articles}

      {_, response} ->
        {:error, response}
    end
  end

  def article_details(article), do: {:ok, article}

  defp parse_article(article) do
    %{
      "description" => description,
      "guid" => %{
        "value" => url
      },
      "pub_date" => date,
      "title" => title
    } = article

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)

    image =
      case Regex.named_captures(~r/src="(?<url>[^"]+)"/, description) do
        %{"url" => image_url} ->
          URI.encode(image_url)

        _ ->
          nil
      end

    description =
      description
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

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
      image: image,
      url: url
    }
  end
end
