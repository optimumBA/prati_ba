defmodule PratiBa.Scrapers.Scraper do
  @callback articles() :: {:ok, []} | {:error, %Mojito.Error{}}
  @callback source_name() :: String.t
end
