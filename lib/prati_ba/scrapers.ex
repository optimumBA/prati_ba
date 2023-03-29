defmodule PratiBa.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias PratiBa.Articles

  def list do
    scrapers = Application.get_env(:prati_ba, :scrapers)

    Articles.list_sources()
    |> Stream.map(&get_scraper(&1, scrapers))
    |> Stream.reject(&is_nil/1)
    |> Enum.to_list()
  end

  defp get_scraper(source = %Articles.Source{name: source_name}, scrapers) do
    case Map.get(scrapers, source_name) do
      nil ->
        nil

      scraper ->
        {source, scraper}
    end
  end
end
