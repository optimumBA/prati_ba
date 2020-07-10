defmodule PratiBa.Scrapers.ScrapingHelper do
  def get_og_image(html) do
    html
    |> Floki.find("meta[property=\"og:image\"]")
    |> Floki.attribute("content")
    |> Enum.at(0)
    |> URI.encode()
  end
end
