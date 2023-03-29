defmodule Mix.Tasks.PratiBa.Scrapers.FetchNewArticles do
  use Mix.Task

  @shortdoc "Fetches new articles"

  def run(_) do
    Mix.Task.run("app.start")

    PratiBa.ScrapingPipeline.start()
  end
end
