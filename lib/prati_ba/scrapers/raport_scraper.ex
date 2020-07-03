defmodule PratiBa.Scrapers.RaportScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url_base "https://raport.ba"

  def articles(url_base \\ @url_base) do
    response = Mojito.request(method: :get, url: url_base <> "/wp-json/wp/v2/posts/")

    with {:ok, %{status_code: 200, body: body}} <- response,
         body <- HtmlEntities.decode(body),
         {:ok, articles} <- Jason.decode(body) do
      articles =
        articles
        |> Stream.map(&fetch_image(&1, url_base))
        |> Stream.map(&Task.await(&1, 5000))
        |> Stream.map(&parse_article/1)

      {:ok, articles}
    else
      {_, response} -> {:error, response}
    end
  end

  defp fetch_image(article, url_base) do
    case article["featured_media"] do
      id when is_integer(id) ->
        Task.async(fn ->
          response = Mojito.request(method: :get, url: "#{url_base}/wp-json/wp/v2/media/#{id}")

          with {:ok, %{status_code: 200, body: body}} <- response,
               {:ok, media} <- Jason.decode(body),
               %{"media_details" => %{"sizes" => %{"full" => %{"source_url" => image_url}}}} <- media do
            image_url = URI.encode(image_url)
            {article, image_url}
          else
            _ -> {article, nil}
          end
        end)
      _ ->
        {article, nil}
    end
  end

  defp parse_article({article, image_url}) do
    %{
      "id" => original_id,
      "date_gmt" => published_at,
      "link" => url,
      "title" => %{
        "rendered" => title,
      },
      "excerpt" => %{
        "rendered" => description,
      },
    } = article

    title =
      title
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    description =
      description
      |> HtmlSanitizeEx.strip_tags()
      |> String.trim()

    %{
      original_id: Integer.to_string(original_id),
      title: HtmlSanitizeEx.strip_tags(title),
      description: HtmlSanitizeEx.strip_tags(description),
      published_at: Timex.parse!(published_at, "{RFC3339}"),
      author: nil,
      image: image_url,
      url: URI.encode(url),
    }
  end
end
