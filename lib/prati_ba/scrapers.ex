defmodule PratiBa.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias PratiBa.Articles
  alias PratiBa.Articles.Source
  alias PratiBa.Scrapers.{KlixScraper, RadioSarajevoScraper}

  @scrapers %{
    "Klix.ba" => KlixScraper,
    "radiosarajevo.ba" => RadioSarajevoScraper,
  }

  @article_keys [:image, :published_at, :title, :url]

  def fetch_new_articles(scrapers \\ @scrapers) do
    Articles.list_sources()
    |> Stream.map(&get_scraper(&1, scrapers))
    |> Enum.map(&scrape_articles/1)
    |> Enum.each(&Task.await(&1, 15000))
  end

  defp get_scraper(source = %Source{name: source_name}, scrapers) do
    %{^source_name => scraper} = scrapers

    {source, scraper}
  end

  defp scrape_articles({source, scraper}) do
    Task.async(fn ->
      case scraper.articles() do
        {:ok, articles} ->
          articles
          |> Stream.reject(&Articles.exists?/1)
          |> Stream.map(&Map.take(&1, @article_keys))
          |> Enum.each(&Articles.create_article(source, &1))
        {:error, _} ->
          nil
      end
    end)
  end
end
