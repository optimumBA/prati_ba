defmodule PratiBa.ScrapingPipeline.ArticlesListConsumerSupervisor do
  use ConsumerSupervisor

  require Logger

  alias PratiBa.ScrapingPipeline.{ArticlesListConsumer, ScraperProducer}

  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

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
