defmodule PratiBa.Scrapers.RadioSlobodnaEvropaScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.slobodnaevropa.org/api/zqtovekoir"

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

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
      "author" => author,
      "description" => description,
      "enclosure" => %{
        "url" => image
      },
      "link" => url,
      "pub_date" => date,
      "title" => title
    } = article

    author =
      with false <- is_nil(author),
           %{"author" => author} <- Regex.named_captures(~r/\((?<author>[^\)]+)\)$/, author) do
        author
      else
        _ -> nil
      end

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)
      |> String.split(".")
      |> Enum.fetch!(0)

    published_at =
      date
      |> Timex.parse!("{RFC1123}")
      |> DateTime.shift_zone!("Etc/UTC")
      |> DateTime.to_naive()

    image_url =
      case image do
        nil ->
          nil

        image_url ->
          URI.encode(image_url)
      end

    %{
      original_id: original_id,
      title: title,
      description: description,
      published_at: published_at,
      author: author,
      image: image_url,
      url: url
    }
  end
end
