defmodule PratiBa.ScrapingPipeline.ArticlesListConsumerSupervisor do
  @moduledoc false

  use ConsumerSupervisor

  alias PratiBa.ScrapingPipeline.ArticlesListConsumer
  alias PratiBa.ScrapingPipeline.ScraperProducer

  require Logger

  @spec start_link(any) :: {:ok, pid} | :ignore | {:error, any}
  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

  @impl ConsumerSupervisor
  def init(:ok) do
    Logger.info("ArticlesListConsumerSupervisor init")

    children = [
      %{
        id: ArticlesListConsumer,
        start: {ArticlesListConsumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {ScraperProducer, max_demand: 5}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
