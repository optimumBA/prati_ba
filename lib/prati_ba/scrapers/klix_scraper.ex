defmodule PratiBa.Scrapers.KlixScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.klix.ba/rss/svevijesti"
  @source_name "Klix.ba"

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, rss} = FastRSS.parse(body)
        {:ok, parse_articles(rss["items"])}
      {_, response} ->
        {:error, response}
    end
  end

  def source_name(), do: @source_name

  defp parse_articles(items, articles \\ [])
  defp parse_articles([], articles), do: articles
  defp parse_articles([head|tail], articles) do
    %{
      "categories" => [
        %{
          "name" => category,
        },
      ],
      "description" => description,
      "dublin_core_ext" => %{
        "creators" => [author],
      },
      "extensions" => image_properties,
      "link" => url,
      "pub_date" => date,
      "title" => title,
    } = head

    id = url
    |> String.split("/")
    |> Enum.fetch!(-1)
    |> String.to_integer()

    published_at = date
    |> Timex.parse!("{RFC1123}")
    |> DateTime.shift_zone!("Etc/UTC")
    |> DateTime.to_naive()

    image = case image_properties do
      %{
        "media" => %{
          "content" => [
            %{
              "attrs" => %{
                "url" => image_url,
              },
            },
          ],
        },
      } ->
        URI.encode(image_url)
      _ ->
        nil
    end

    article = %{
      id: id,
      title: title,
      description: description,
      category: category,
      published_at: published_at,
      author: author,
      image: image,
      url: URI.encode(url),
    }

    parse_articles(tail, articles ++ [article])
  end
end
