defmodule PratiBa.RadioSarajevoScraper do
  @rss_url "https://radiosarajevo.ba/rss"

  def articles(url \\ @rss_url) do
    response = Mojito.request(method: :get, url: url)

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        body = String.trim(body)
        {:ok, feed, _} = FeederEx.parse(body)
        {:ok, parse_articles(feed.entries)}
      {_, response} ->
        {:error, response}
    end
  end

  defp parse_articles(items, articles \\ [])
  defp parse_articles([], articles), do: articles
  defp parse_articles([head|tail], articles) do
    %FeederEx.Entry{
      author: author,
      link: url,
      summary: summary,
      title: title,
      updated: date,
    } = head

    id = url
    |> String.split("/")
    |> Enum.fetch!(-1)
    |> String.to_integer()

    category = case Regex.named_captures(~r/https:\/\/radiosarajevo.ba\/(?<category>[^\/]+)\//, url) do
      %{"category" => category} ->
        String.capitalize(category)
      nil ->
        nil
    end

    published_at = date
    |> Timex.parse!("{RFC3339}")
    |> DateTime.shift_zone!("Etc/UTC")
    |> DateTime.to_naive()

    image = case Regex.named_captures(~r/src="(?<url>https:\/\/storage.radiosarajevo.ba\/article\/\d+\/(?<width>\d+)x(?<height>\d+)[^"]+)"/, summary) do
      %{"url" => image_url, "height" => image_height, "width" => image_width} ->
        %{
          url: image_url,
          width: image_width,
          height: image_height,
          credit: nil,
        }
      nil ->
        nil
    end

    article = %{
      id: id,
      title: title,
      description: nil,
      category: category,
      published_at: published_at,
      author: author,
      image: image,
      url: url,
    }

    parse_articles(tail, articles ++ [article])
  end
end
