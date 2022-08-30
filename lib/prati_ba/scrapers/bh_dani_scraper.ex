defmodule PratiBa.Scrapers.BhDaniScraper do
  @behaviour PratiBa.Scrapers.Scraper

  @url "https://bhdani.oslobodjenje.ba/bhdani/"

  alias PratiBa.Scrapers.ScrapingHelper

  def articles(url \\ @url) do
    response = ScrapingHelper.get(url)

    with {:ok, %{status_code: 200, body: body}} <- response,
    {:ok, html} <- Floki.parse_document(body) do

    end

  end
end
