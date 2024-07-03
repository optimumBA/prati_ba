defmodule PratiBa.ScrapingPipeline.ArticleConsumer do
  @moduledoc false

  alias PratiBa.Articles

  require Logger

  @article_keys [:image, :original_id, :published_at, :title, :url]

  @spec start_link(any()) :: any()
  def start_link({source, scraper, article} = event) do
    Logger.debug("ArticleConsumer received #{inspect(event)}")

    Task.start_link(fn ->
      with {:ok, article} <- scraper.article_details(article),
           attrs <- Map.take(article, @article_keys) do
        Articles.create_article(source, attrs)
      end
    end)
  end
end
