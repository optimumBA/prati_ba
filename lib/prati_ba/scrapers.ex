defmodule PratiBa.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias PratiBa.Articles
  alias PratiBa.Articles.Source

  alias PratiBa.Scrapers.{
    BljesakScraper,
    DnevniAvazScraper,
    FaceScraper,
    KlixScraper,
    N1Scraper,
    OslobodjenjeScraper,
    PrvaSmjenaScraper,
    RadioSarajevoScraper,
    RadioSlobodnaEvropaScraper,
    RaportScraper,
    SlobodnaBosnaScraper,
    TheBosniaTimesScraper,
    ZurnalScraper
  }

  @scrapers %{
    "Bljesak.info" => BljesakScraper,
    "Dnevni avaz" => DnevniAvazScraper,
    "face.ba" => FaceScraper,
    "Klix.ba" => KlixScraper,
    "N1" => N1Scraper,
    "Oslobođenje" => OslobodjenjeScraper,
    "Prva smjena" => PrvaSmjenaScraper,
    "Radio Sarajevo" => RadioSarajevoScraper,
    "Radio Slobodna Evropa" => RadioSlobodnaEvropaScraper,
    "Raport.ba" => RaportScraper,
    "Slobodna Bosna" => SlobodnaBosnaScraper,
    "The Bosnia Times" => TheBosniaTimesScraper,
    "Žurnal" => ZurnalScraper
  }

  @article_keys [:image, :original_id, :published_at, :title, :url]

  def fetch_new_articles(scrapers \\ @scrapers) do
    Articles.list_sources()
    |> Stream.map(&get_scraper(&1, scrapers))
    |> Stream.reject(&is_nil/1)
    |> Enum.map(&scrape_articles/1)
    |> Enum.each(&Task.await(&1, 30000))
  end

  defp get_scraper(source = %Source{name: source_name}, scrapers) do
    case Map.get(scrapers, source_name) do
      nil -> nil
      scraper -> {source, scraper}
    end
  end

  defp scrape_articles({source, scraper}) do
    Task.async(fn ->
      case scraper.articles() do
        {:ok, articles} ->
          articles
          |> Stream.reject(&Articles.exists?(source.id, &1))
          |> Enum.map(&Task.async(fn -> scraper.article_details(&1) end))
          |> Enum.map(&Task.await(&1, 10000))
          |> Stream.filter(&successful?/1)
          |> Stream.map(&transform_article/1)
          |> Enum.each(&Articles.create_article(source, &1))

        {:error, _} ->
          nil
      end
    end)
  end

  defp successful?({:ok, _}), do: true
  defp successful?({:error, _}), do: false

  defp transform_article({:ok, article}), do: Map.take(article, @article_keys)
end
