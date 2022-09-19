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
                 author: "Srna",
                 description:
                   "GRADIŠKA - Predsjednik Socijalističke partije Srpske /SPS/ Goran Selak izrazio je očekivanje da će ova stranka, bez obzira što prvi put izlazi na opšte izbore, imati veliku podršku građana i da će u svih devet izbornih jedinica za Narodnu skupštinu Republike Srpske imati direktno izabrane ...",
                 image: "https://slika.nezavisne.rs/2022/09/750x450/20220919192746_736572.jpg",
                 original_id: "736572",
                 published_at: ~N[2022-09-19 17:27:46],
                 title: "Selak: Imaćemo direktno izabrane poslanike iz svih izbornih jedinica",
                 url:
                   "https://www.nezavisne.com/novosti/bih/Selak-Imacemo-direktno-izabrane-poslanike-iz-svih-izbornih-jedinica/736572"
               }
             ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/nezavisne_novine_scraper/feed.xml")
  end
end
