defmodule PratiBa.Scrapers.NezavisneNovineScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.NezavisneNovineScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = NezavisneNovineScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "609688",
                 title: "Stefanović: Pronađene patrone suzavca koje MUP ne koristi",
                 description:
                   "BEOGRAD - Ministar policije Nebojša Stefanović izjavio je danas da su na prostoru oko Skupštine Srbije pronađene patrone suzavca koje MUP ne koristi.",
                 published_at: ~N[2020-07-10 07:46:35],
                 author: nil,
                 image: "https://slika.nezavisne.rs/2020/07/555x333/20200710094635_609688.jpg",
                 url:
                   "https://www.nezavisne.com/novosti/ex-yu/Stefanovic-Pronadjene-patrone-suzavca-koje-MUP-ne-koristi/609688"
               }
             ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/nezavisne_novine_scraper/feed.xml")
  end
end
