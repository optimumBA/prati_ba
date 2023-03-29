defmodule PratiBa.ScrapingPipeline.ArticleConsumerSupervisor do
  use ConsumerSupervisor

  require Logger

  alias PratiBa.ScrapingPipeline.{ArticleConsumer, ArticleProducer}

  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    Logger.info("ArticleConsumerSupervisor init")

    children = [
      %{
        id: ArticleConsumer,
        start: {ArticleConsumer, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {ArticleProducer, max_demand: 10}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
