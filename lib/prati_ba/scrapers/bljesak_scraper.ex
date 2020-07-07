defmodule PratiBa.Scrapers.BljesakScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://www.bljesak.info/najnovije"

  def articles(url \\ @url) do
    response = Mojito.request(method: :get, url: url)

    with {:ok, %{status_code: 200, body: body}} <- response,
         {:ok, html} <- Floki.parse_document(body) do
      articles =
        html
        |> Floki.find("article")
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
        |> Floki.find("article")

      description =
        article_container
        |> Floki.find(".intro")
        |> Floki.text()
        |> String.trim()

      article =
        case description do
          "" -> article
          description -> Map.put(article, :description, description)
        end

      date =
        article_container
        |> Floki.find(".info span")
        |> Enum.at(-2)
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
        case Floki.find(article_container, ".box a img") do
          [image | _] ->
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
    link =
      article
      |> Floki.find(".title a")

    url =
      link
      |> Floki.attribute("href")
      |> Enum.at(0)
      |> URI.encode()

    original_id =
      url
      |> String.split("/")
      |> Enum.fetch!(-1)

    title =
      link
      |> Floki.text()
      |> String.trim()

    image =
      article
      |> Floki.find(".image img")
      |> Floki.attribute("src")
      |> Enum.at(0)
      |> URI.encode()

    %{
      original_id: original_id,
      title: title,
      description: nil,
      published_at: nil,
      author: nil,
      image: image,
      url: url
    }
  end
end
