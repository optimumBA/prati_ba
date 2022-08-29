defmodule PratiBa.Scrapers.BhDaniTest do
  use ExUnit.Case, async: true
  alias PratiBa.Scrapers.BhDaniScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)
  end

  def articles_payload do

  end

end
