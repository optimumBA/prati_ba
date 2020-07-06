defmodule PratiBa.Scrapers.Scraper do
  @callback articles() :: {:ok, []} | {:error, %Mojito.Error{}}
  @callback article_details(map()) :: {:ok, map()} | {:error, %Mojito.Error{}}
end
