defmodule Mix.Tasks.PratiBa.Scrapers.FetchNewArticles do
  @shortdoc "Fetches new articles"

  @moduledoc false

  use Mix.Task

  @spec run(any()) :: :ok
  def run(_args) do
    Mix.Task.run("app.start")

    PratiBa.ScrapingPipeline.start()
  end
end
