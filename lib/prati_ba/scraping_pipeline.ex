defmodule PratiBa.ScrapingPipeline do
  use Supervisor

  alias PratiBa.ScrapingPipeline.{
    ArticleConsumerSupervisor,
    ArticleProducer,
    ArticlesListConsumerSupervisor,
    ScraperProducer
  }

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @impl Supervisor
  def init(:ok) do
    children = [
      ScraperProducer,
      ArticlesListConsumerSupervisor,
      ArticleProducer,
      ArticleConsumerSupervisor
    ]

    opts = [strategy: :one_for_one, name: PratiBa.ScrapingPipeline]
    Supervisor.init(children, opts)
  end
end
