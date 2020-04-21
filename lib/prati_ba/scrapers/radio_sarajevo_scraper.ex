defmodule PratiBa.Scrapers.RadioSarajevoScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @rss_url "https://radiosarajevo.ba/rss"

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, feed, _} = body
          |> HtmlEntities.decode()
          |> String.trim()
          |> FeederEx.parse()

        articles = feed.entries
        |> Stream.map(&parse_article/1)

        {:ok, articles}
      {_, response} ->
        {:error, response}
    end
  end

  defp parse_article(article) do
    %FeederEx.Entry{
      author: author,
      link: url,
      summary: summary,
      title: title,
      updated: date,
    } = article

    id = url
    |> String.split("/")
    |> Enum.fetch!(-1)
    |> String.to_integer()

    published_at = date
    |> Timex.parse!("{RFC3339}")
    |> DateTime.shift_zone!("Etc/UTC")
    |> DateTime.to_naive()

    image = case Regex.named_captures(~r/src="(?<url>[^"]+)"/, summary) do
      %{"url" => image_url} ->
        URI.encode(image_url)
      _ ->
        nil
    end

    %{
      id: id,
      title: title,
      description: nil,
      category: parse_category(url),
      published_at: published_at,
      author: author,
      image: image,
      url: URI.encode(url),
    }
  end

  defp parse_category("https://radiosarajevo.ba/vijesti/bosna-i-hercegovina" <> _), do: "BiH"
  defp parse_category("https://radiosarajevo.ba/vijesti/regija" <> _), do: "Regija"
  defp parse_category("https://radiosarajevo.ba/vijesti/svijet" <> _), do: "Svijet"
  defp parse_category("https://radiosarajevo.ba/biznis" <> _), do: "Ekonomija"
  defp parse_category("https://radiosarajevo.ba/magazin/tech" <> _), do: "Nauka i tehnologija"
  defp parse_category("https://radiosarajevo.ba/kolumne" <> _), do: "Kolumne"
  defp parse_category("https://radiosarajevo.ba/sport" <> _), do: "Sport"
  defp parse_category("https://radiosarajevo.ba/auto-moto" <> _), do: "Auto"
  defp parse_category("https://radiosarajevo.ba/metromahala/zmajevi" <> _), do: "Humanost"
  defp parse_category("https://radiosarajevo.ba/magazin" <> _), do: "Zabava"
  defp parse_category("https://radiosarajevo.ba/metromahala" <> _), do: "Zabava"
  defp parse_category(_), do: nil
end
