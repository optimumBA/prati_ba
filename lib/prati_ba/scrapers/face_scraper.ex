defmodule PratiBa.Scrapers.FaceScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://www.face.ba/najnovije"

  def articles(url \\ @url) do
    response = Mojito.request(method: :get, url: url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find(".headline-bottom .article a")
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
        |> Floki.find(".main-article")
        |> Enum.at(-1)

      description =
        article_container
        |> Floki.find(".main-article-small-headline")
        |> Floki.text()
        |> String.trim()

      article =
        case description do
          "" -> article
          description -> Map.put(article, :description, description)
        end

      date =
        article_container
        |> Floki.find(".main-article-info-span")
        |> Enum.at(0)
        |> Floki.text()
        |> String.trim()

      published_at =
        date
        |> Timex.parse!("{D}. {M}. {YYYY}. u {h24}:{m}")
        |> DateTime.from_naive!("Europe/Sarajevo")
        |> DateTime.shift_zone!("Etc/UTC")
        |> DateTime.to_naive()

      article = Map.put(article, :published_at, published_at)

      article =
        case Floki.find(article_container, ".main-article-image-wrapper img") do
          [image] ->
            image_url =
              image
              |> Floki.attribute("src")
              |> Enum.at(0)
              |> URI.encode()

            Map.put(article, :image, image_url)

          _ ->
            article
        end

      {:ok, article}
    else
      _ -> {:ok, article}
    end
  end

  defp parse_article(article) do
    url =
      article
      |> Floki.attribute("href")
      |> Enum.at(0)

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)

    title =
      article
      |> Floki.find(".article-title")
      |> Floki.text()
      |> String.trim()

    background =
      article
      |> Floki.find(".article-background")
      |> Floki.attribute("style")
      |> Enum.at(0)

    image =
      case Regex.named_captures(~r/background:url\('(?<url>[^']+)'\);/, background) do
        %{"url" => image_url} ->
          URI.encode(image_url)

        _ ->
          nil
      end

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: nil,
      author: nil,
      image: image,
      url: URI.encode(url)
    }
  end
end
