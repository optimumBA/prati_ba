defmodule PratiBa.ScrapingPipeline.ArticleProducer do
  @moduledoc false

  use GenStage

  require Logger

  @spec start_link([]) :: {:ok, pid} | :ignore | {:error, any}
  def start_link([]) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec add_articles(list()) :: :ok
  def add_articles(articles) do
    GenStage.cast(__MODULE__, {:add_articles, articles})
  end

  @impl GenStage
  def init([]) do
    {:producer, %{demand: 0, articles: []}}
  end

  @impl GenStage
  def handle_cast({:add_articles, articles}, state) do
    Logger.info("ArticleProducer handle_cast #{inspect(state.demand)}")

    {articles, rest} = Enum.split(articles, state.demand)

    new_state =
      state
      |> Map.put(:articles, rest)
      |> Map.put(:demand, state.demand - length(articles))

    {:noreply, articles, new_state}
  end

  @impl GenStage
  def handle_demand(demand, state) do
    Logger.info("ArticleProducer handle_demand #{inspect(demand)} #{inspect(state.demand)}")

    {articles, rest} = Enum.split(state.articles, state.demand + demand)

    new_demand = state.demand + demand - length(articles)

    new_state =
      state
      |> Map.put(:articles, rest)
      |> Map.put(:demand, new_demand)

    {:noreply, articles, new_state}
  end
end
