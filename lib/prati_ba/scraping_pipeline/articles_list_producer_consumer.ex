defmodule PratiBa.ScrapingPipeline.ArticlesListProducerConsumer do
  use GenStage

  alias PratiBa.Articles
  alias PratiBa.ScrapingPipeline.{ScraperProducer, ScrapingRegistry}

  require Logger

  def start_link(id) do
    GenStage.start_link(__MODULE__, [], name: via(id))
  end

  @impl GenStage
  def init([]) do
    {:producer_consumer, %{articles: [], demand: 0},
     subscribe_to: [{ScraperProducer, min_demand: 0, max_demand: 1}]}
  end

  def via(id) do
    {:via, Registry, {ScrapingRegistry, process_id(id)}}
  end

  def process_id(id) do
    "articles_list_producer_consumer_#{id}"
  end

  @impl GenStage
  def handle_demand(demand, state) do
    Logger.warn(
      "ArticlesListProducerConsumer handle_demand #{inspect(demand)} #{inspect(state.demand)}"
    )

    {articles, rest} = Enum.split(state.articles, state.demand + demand)

    new_demand = state.demand + demand - length(articles)

    new_state =
      state
      |> Map.put(:demand, new_demand)
      |> Map.put(:articles, rest)

    {:noreply, articles, new_state}
  end

  @impl GenStage
  def handle_events([{source, scraper}], _from, state) do
    Logger.warn("ArticlesListProducerConsumer: #{source.name} #{inspect(state.demand)}")

    new_articles =
      case scraper.articles() do
        {:ok, new_articles} ->
          new_articles
          |> Stream.reject(&Articles.exists?(source.id, &1))
          |> Enum.map(fn article -> {source, scraper, article} end)

        {:error, _} ->
          []
      end

    all_articles = Enum.concat(state.articles, new_articles)

    {articles, rest} = Enum.split(all_articles, state.demand)

    new_state =
      state
      |> Map.put(:articles, rest)
      |> Map.put(:demand, state.demand - length(articles))

    {:noreply, articles, new_state}
  end
end
