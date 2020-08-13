defmodule PratiBa.Scrapers.ScrapingHelper do
  def get_og_image(html) do
    image_url =
      html
      |> Floki.find("meta[property=\"og:image\"]")
      |> Floki.attribute("content")
      |> Enum.at(0)

    case image_url do
      nil ->
        {:error, :image_not_available}

      image_url ->
        {:ok, URI.encode(image_url)}
    end
  end

  def get_og_description(html) do
    description =
      html
      |> Floki.find("meta[property=\"og:description\"]")
      |> Floki.attribute("content")
      |> Enum.at(0)

    case description do
      nil ->
        {:error, :description_not_available}

      description ->
        {:ok, String.trim(description)}
    end
  end
end
