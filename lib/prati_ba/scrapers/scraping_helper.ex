defmodule PratiBa.Scrapers.ScrapingHelper do
  @moduledoc false

  @user_agent Application.compile_env(:prati_ba, :user_agent, "")

  @spec get(String.t()) :: {:ok, map()} | {:error, any()}
  def get(url) do
    :get
    |> Finch.build(url, [{"user-agent", @user_agent}])
    |> Finch.request(PratiBa.Finch)
  end

  @spec get_og_image(Floki.html_tree()) :: {:ok, binary()} | {:error, any()}
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

  @spec get_og_description(Floki.html_tree()) :: {:ok, String.t()} | {:error, any()}
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
