defmodule PratiBa.ScrapingPipeline.ArticleConsumerSupervisor do
  @moduledoc false

  use ConsumerSupervisor

  alias PratiBa.ScrapingPipeline.ArticleConsumer
  alias PratiBa.ScrapingPipeline.ArticleProducer

  require Logger

  @spec start_link(any) :: {:ok, pid} | :ignore | {:error, any}
  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :ok)
  end

  @impl ConsumerSupervisor
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
