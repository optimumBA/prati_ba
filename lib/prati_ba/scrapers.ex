defmodule PratiBa.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias PratiBa.Articles
  alias PratiBa.Articles.Source

  alias PratiBa.Scrapers.{
    # BhDaniScraper,
    BljesakScraper,
    # CapitalBaScraper,
    CinScraper,
    DnevniAvazScraper,
    DwScraper,
    FaceScraper,
    FokusScraper,
    # FrontalScraper,
    KlixScraper,
    N1Scraper,
    NezavisneNovineScraper,
    OslobodjenjeScraper,
    # PreokretInfoScraper,
    PrvaSmjenaScraper,
    RadioSarajevoScraper,
    RadioSlobodnaEvropaScraper,
    RaportScraper,
    RaskrinkavanjeScraper,
    SlobodnaBosnaScraper,
    SourceScraper,
    # StartBihScraper,
    TheBosniaTimesScraper,
    ZurnalScraper
  }

  @scrapers %{
    # "BH Dani" => BhDaniScraper,
    "Bljesak.info" => BljesakScraper,
    # "Capital.ba" => CapitalBaScraper,
    "CIN" => CinScraper,
    "Dnevni avaz" => DnevniAvazScraper,
    "DW" => DwScraper,
    "face.ba" => FaceScraper,
    "Fokus.ba" => FokusScraper,
    # "Frontal.ba" => FrontalScraper,
    "Klix.ba" => KlixScraper,
    "N1" => N1Scraper,
    "Nezavisne novine" => NezavisneNovineScraper,
    "Oslobođenje" => OslobodjenjeScraper,
    # "Preokret.info" => PreokretInfoScraper,
    "Prva smjena" => PrvaSmjenaScraper,
    "Radio Sarajevo" => RadioSarajevoScraper,
    "Radio Slobodna Evropa" => RadioSlobodnaEvropaScraper,
    "Raport.ba" => RaportScraper,
    "Raskrinkavanje.ba" => RaskrinkavanjeScraper,
    "Slobodna Bosna" => SlobodnaBosnaScraper,
    "source.ba" => SourceScraper,
    # "Start BiH" => StartBihScraper,
    "The Bosnia Times" => TheBosniaTimesScraper,
    "Žurnal" => ZurnalScraper
  }

  @article_keys [:image, :original_id, :published_at, :title, :url]

  def fetch_new_articles(scrapers \\ @scrapers) do
    Articles.list_sources()
    |> Stream.map(&get_scraper(&1, scrapers))
    |> Stream.reject(&is_nil/1)
    |> Enum.map(&scrape_articles/1)
  end

  defp get_scraper(source = %Source{name: source_name}, scrapers) do
    case Map.get(scrapers, source_name) do
      nil ->
        nil

      scraper ->
        {source, scraper}
    end
  end

  defp scrape_articles({source, scraper}) do
    case scraper.articles() do
      {:ok, articles} ->
        articles
        |> Stream.reject(&Articles.exists?(source.id, &1))
        |> Enum.map(&get_article_details(scraper, &1))
        |> Stream.filter(&successful?/1)
        |> Stream.map(&transform_article/1)
        |> Enum.each(&Articles.create_article(source, &1))

      {:error, _} ->
        nil
    end
  end

  defp get_article_details(scraper, article) do
    Timber.add_context(article: article)
    scraper.article_details(article)
  end

  defp successful?({:ok, _}), do: true
  defp successful?({:error, _}), do: false

  defp transform_article({:ok, article}), do: Map.take(article, @article_keys)
end
