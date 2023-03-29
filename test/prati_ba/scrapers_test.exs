defmodule PratiBa.ScrapersTest do
  use PratiBa.DataCase, async: false

  alias PratiBa.Articles
  alias PratiBa.Scrapers
  alias PratiBa.Scrapers.ScraperMock

  describe "list/0" do
    setup do
      %{source: insert(:source, name: "Fake source")}
    end

    test "gets scrapers from the DB", %{source: %Articles.Source{} = source} do
      Application.put_env(:prati_ba, :scrapers, %{source.name => ScraperMock})
      assert Scrapers.list() == [{source, ScraperMock}]
    end

    test "doesn't crash if the scraper module doesn't exist" do
      Application.put_env(:prati_ba, :scrapers, %{})
      assert Scrapers.list() == []
    end
  end
end
