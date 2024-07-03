defmodule PratiBa.ScrapingPipeline.ArticlesListConsumer do
  @moduledoc false

  alias PratiBa.Articles
  alias PratiBa.ScrapingPipeline.ArticleProducer

  require Logger

  @spec start_link({any, any}) :: {:ok, pid}
  def start_link({source, scraper} = event) do
    Logger.debug("ArticlesListConsumer received #{inspect(event)}")

    Task.start_link(fn ->
      case scraper.articles() do
        {:ok, new_articles} ->
          new_articles
          |> Stream.reject(&Articles.exists?(source.id, &1))
          |> Enum.map(fn article -> {source, scraper, article} end)
          |> ArticleProducer.add_articles()

        {:error, _other} ->
          nil
      end
    end)
  end
end
