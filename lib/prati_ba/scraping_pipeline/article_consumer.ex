defmodule PratiBa.ScrapingPipeline.ArticleConsumer do
  use GenStage

  alias PratiBa.Articles
  alias PratiBa.ScrapingPipeline.{ArticlesListProducerConsumer, ScrapingRegistry}

  @article_keys [:image, :original_id, :published_at, :title, :url]

  require Logger

  def start_link(id) do
    GenStage.start_link(__MODULE__, :ok, name: via(id))
  end

  def init(:ok) do
    {:consumer, :no_state,
     subscribe_to: [
       articles_list_producer_consumer(id: 1),
       articles_list_producer_consumer(id: 2),
       articles_list_producer_consumer(id: 3),
       articles_list_producer_consumer(id: 4),
       articles_list_producer_consumer(id: 5)
     ]}
  end

  defp articles_list_producer_consumer(id: id) do
    {ArticlesListProducerConsumer.via(id), [min_demand: 0, max_demand: 1]}
  end

  def via(id) do
    {:via, Registry, {ScrapingRegistry, process_id(id)}}
  end

  def process_id(id) do
    "article_consumer_#{id}"
  end

  def handle_events([{source, scraper, article}], _from, state) do
    Logger.warn("ArticleConsumer: #{article.url}")

    with {:ok, article} <- scraper.article_details(article),
         attrs <- Map.take(article, @article_keys) do
      Articles.create_article(source, attrs)
    end

    {:noreply, [], state}
  end
end
