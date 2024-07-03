defmodule PratiBa.ScrapingPipeline.ScraperProducer do
  @moduledoc false

  use GenStage

  alias PratiBa.Scrapers

  require Logger

  @spec start_link([]) :: {:ok, pid} | :ignore | {:error, any}
  def start_link([]) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec get_scrapers() :: :ok
  def get_scrapers do
    GenStage.cast(__MODULE__, :get_scrapers)
  end

  @impl GenStage
  def init([]) do
    {:producer, %{demand: 0, scrapers: []}}
  end

  @impl GenStage
  def handle_cast(:get_scrapers, state) do
    scrapers = Scrapers.list()

    Logger.info("ScraperProducer handle_cast #{inspect(state.demand)}")

    {split_scrapers, rest} = Enum.split(scrapers, state.demand)

    new_state =
      state
      |> Map.put(:demand, state.demand - length(split_scrapers))
      |> Map.put(:scrapers, rest)

    {:noreply, split_scrapers, new_state}
  end

  @impl GenStage
  def handle_demand(demand, state) do
    Logger.info("ScraperProducer handle_demand #{inspect(demand)} #{inspect(state.demand)}")

    {scrapers, rest} = Enum.split(state.scrapers, state.demand + demand)

    new_demand = state.demand + demand - length(scrapers)

    new_state =
      state
      |> Map.put(:demand, new_demand)
      |> Map.put(:scrapers, rest)

    {:noreply, scrapers, new_state}
  end
end
