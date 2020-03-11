defmodule PratiBa.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias PratiBa.Articles
  alias PratiBa.Scrapers.{KlixScraper, RadioSarajevoScraper}

  @scrapers [
    KlixScraper,
    RadioSarajevoScraper,
  ]

  def fetch_new_articles(scrapers \\ @scrapers)
  def fetch_new_articles([]), do: nil
  def fetch_new_articles([scraper|tail]) do
    case scraper.articles() do
      {:ok, articles} ->
        source = Articles.get_source!(scraper.source_name)
        save_new_articles(articles, source)
      {:error, _} ->
        nil
    end

    fetch_new_articles(tail)
  end

  defp save_new_articles([], _), do: nil
  defp save_new_articles([head|tail], source) do
    unless Articles.exists?(head) do
      %{
        image: %{
          url: image_url,
        },
        published_at: published_at,
        title: title,
        url: url,
      } = head

      Articles.create_article(source, %{
        image: image_url,
        published_at: published_at,
        title: title,
        url: url,
      })
    end

    save_new_articles(tail, source)
  end
end
