defmodule PratiBa.Scrapers.KlixScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://www.klix.ba/rss/svevijesti"

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, rss} = FastRSS.parse(body)

        articles = rss["items"]
        |> Stream.map(&parse_article/1)

        {:ok, articles}
      {_, response} ->
        {:error, response}
    end
  end

  defp parse_article(article) do
    %{
      "description" => description,
      "dublin_core_ext" => %{
        "creators" => [author],
      },
      "extensions" => image_properties,
      "link" => url,
      "pub_date" => date,
      "title" => title,
    } = article

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

    %{
      id: id,
      title: title,
      description: description,
      category: parse_category(url),
      published_at: published_at,
      author: author,
      image: image,
      url: URI.encode(url),
    }
  end

  defp parse_category("https://www.klix.ba/vijesti/bih" <> _), do: "BiH"
  defp parse_category("https://www.klix.ba/vijesti/regija" <> _), do: "Regija"
  defp parse_category("https://www.klix.ba/vijesti/svijet" <> _), do: "Svijet"
  defp parse_category("https://www.klix.ba/biznis" <> _), do: "Ekonomija"
  defp parse_category("https://www.klix.ba/scitech" <> _), do: "Nauka i tehnologija"
  defp parse_category("https://www.klix.ba/sport" <> _), do: "Sport"
  defp parse_category("https://www.klix.ba/auto" <> _), do: "Auto"
  defp parse_category("https://www.klix.ba/vijesti/humanitarne-akcije" <> _), do: "Humanost"
  defp parse_category("https://www.klix.ba/magazin" <> _), do: "Zabava"
  defp parse_category("https://www.klix.ba/lifestyle" <> _), do: "Zabava"
  defp parse_category(_), do: nil
end
