defmodule PratiBa.Scrapers.DnevniAvazScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://avaz.ba/rss"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @rss_url) do
    response = ScrapingHelper.get(url)

    case response do
      {:ok, %{status: 200, body: body}} ->
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
      "extensions" => image_properties,
      "link" => url,
      "pub_date" => date,
      "title" => title
    } = article

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(5)

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    image =
      case image_properties do
        %{
          "media" => %{
            "content" => [
              %{
                "attrs" => %{
                  "url" => image_url
                }
              }
            ]
          }
        } ->
          URI.encode(image_url)

        _ ->
          nil
      end

    %{
      original_id: original_id,
      title: title,
      description: String.trim(description),
      published_at: published_at,
      author: nil,
      image: image,
      url: URI.encode(url)
    }
  end
end
