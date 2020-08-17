defmodule PratiBa.Scrapers.SourceScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "http://www.source.ba"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = Mojito.request(method: :get, url: url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find("#tabNajnovijeC .najnovijeNajcitanijeOkvirVijesti a")
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_, response} -> {:error, response}
    end
  end

  def article_details(%{url: url} = article) do
    response = Mojito.request(method: :get, url: url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      article_container =
        html
        |> Floki.find(".okvirTekstualnogClanka")

      article =
        case Floki.find(article_container, ".uvodTekstualnogClanka") do
          [] ->
            article

          element ->
            description =
              element
              |> Floki.text()
              |> String.trim()

            Map.put(article, :description, description)
        end

      date =
        article_container
        |> Floki.find(".vrijemeObjaveClanka")
        |> Floki.text()
        |> String.trim()

      published_at =
        case Regex.named_captures(
               ~r/^(?<day>\d{1,2})\.(?<month>\d{1,2})\.(?<year>\d{4})\. (?<hour>\d{1,2}):(?<minute>\d{2})$/,
               date
             ) do
          %{
            "day" => day,
            "month" => month,
            "year" => year,
            "hour" => hour,
            "minute" => minute
          } ->
            {{String.to_integer(year), String.to_integer(month), String.to_integer(day)},
             {String.to_integer(hour), String.to_integer(minute), 0}}
            |> NaiveDateTime.from_erl!()
            |> DateTime.from_naive!("Europe/Sarajevo")
            |> DateTime.shift_zone!("Etc/UTC")
            |> DateTime.to_naive()

          _ ->
            nil
        end

      article = Map.put(article, :published_at, published_at)

      text =
        article_container
        |> Floki.find(".tekstTekstualnogClanka")
        |> Floki.text()
        |> String.trim()

      article =
        case Regex.named_captures(~r/\((?<author>[^\)]+)\)$/, text) do
          %{"author" => author} ->
            Map.put(article, :author, author)

          _ ->
            article
        end

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
    path =
      article
      |> Floki.attribute("href")
      |> Enum.at(0)

    original_id =
      path
      |> String.split("/")
      |> Enum.fetch!(3)

    title =
      article
      |> Floki.text()
      |> String.trim()

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: nil,
      author: nil,
      image: nil,
      url: "http://www.source.ba" <> path
    }
  end
end
