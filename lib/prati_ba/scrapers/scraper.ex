defmodule PratiBa.Scrapers.Scraper do
  @callback articles() :: {:ok, []} | {:error, %Mojito.Error{}}
end
