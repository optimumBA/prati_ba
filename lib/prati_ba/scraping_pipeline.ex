defmodule PratiBa.ScrapingPipeline do
  @moduledoc false

  use Supervisor

  alias PratiBa.ScrapingPipeline.ArticleConsumerSupervisor
  alias PratiBa.ScrapingPipeline.ArticleProducer
  alias PratiBa.ScrapingPipeline.ArticlesListConsumerSupervisor
  alias PratiBa.ScrapingPipeline.ScraperProducer

  @spec start() :: :ok
  def start do
    ScraperProducer.get_scrapers()
  end

  @spec start_link(any) :: {:ok, pid} | :ignore | {:error, any}
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

    Supervisor.init(children, strategy: :one_for_one)
  end
end
