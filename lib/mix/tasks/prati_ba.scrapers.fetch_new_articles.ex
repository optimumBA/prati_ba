defmodule Mix.Tasks.PratiBa.Scrapers.FetchNewArticles do
  use Mix.Task

  @shortdoc "Fetches new articles"

  def run(_) do
    Mix.Task.run "app.start"

    PratiBa.Scrapers.fetch_new_articles()
  end
end
