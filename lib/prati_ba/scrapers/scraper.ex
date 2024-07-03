defmodule PratiBa.Scrapers.Scraper do
  @moduledoc false

  @callback articles() :: {:ok, []} | {:error, %Finch.Error{}}
  @callback article_details(map()) :: {:ok, map()} | {:error, %Finch.Error{}}
end
