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
      "extensions" => %{
        "media" => %{
          "content" => [
            %{
              "attrs" => %{
                "url" => image_url,
                "width" => image_width,
              },
              "children" => %{
                "credit" => [
                  %{
                    "value" => image_credit,
                  },
                ],
              },
            },
          ],
        },
      },
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

    article = %{
      id: id,
      title: title,
      description: description,
      category: category,
      published_at: published_at,
      author: author,
      image: %{
        width: image_width,
        url: image_url,
        credit: image_credit,
      },
      url: url,
    }

    parse_articles(tail, articles ++ [article])
  end
end
