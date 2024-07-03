defmodule PratiBa.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias PratiBa.Articles

  @spec list() :: [any()]
  def list do
    scrapers = Application.get_env(:prati_ba, :scrapers)

    Articles.list_sources()
    |> Stream.map(&get_scraper(&1, scrapers))
    |> Stream.reject(&is_nil/1)
    |> Enum.to_list()
  end

  defp get_scraper(%Articles.Source{name: source_name} = source, scrapers) do
    case Map.get(scrapers, source_name) do
      nil ->
        nil

      scraper ->
        {source, scraper}
    end
  end
end
