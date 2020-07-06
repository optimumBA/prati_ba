defmodule PratiBa.Scrapers.OslobodjenjeScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.OslobodjenjeScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end

      response = OslobodjenjeScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response
      assert [
        %{
          original_id: "570770",
          title: "Rasizam u Rusiji: Priče o predrasudama u zemlji gde protesti Crni životi nemaju uticaj",
          description: nil,
          published_at: ~N[2020-07-06 05:14:02],
          author: nil,
          image: "https://cdn.oslobodjenje.ba/images/slike/api/2020/07/06/4614861.jpg",
          url: "https://www.oslobodjenje.ba/vijesti/bbc-news/rasizam-u-rusiji-price-o-predrasudama-u-zemlji-gde-protesti-crni-zivoti-nemaju-uticaj-570770",
        }
      ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/oslobodjenje_scraper/feed.xml")
  end
end
