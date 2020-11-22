defmodule PratiBa.Scrapers.RadioSlobodnaEvropaScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.RadioSlobodnaEvropaScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = RadioSlobodnaEvropaScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "30953162",
                 title: "Kakve promjene očekujete nakon lokalnih izbora u BiH?",
                 description: nil,
                 published_at: ~N[2020-11-16 14:57:00],
                 author: nil,
                 image: nil,
                 url:
                   "https://www.slobodnaevropa.org/a/lokalni-izbori-bih-rezultati/30953162.html"
               },
               %{
                 original_id: "30713005",
                 title: "Srebrenica: Dokumentovani genocid",
                 description:
                   "Dvadeset i pet godina nakon izvršenog genocida u Srebrenici identifikovani su posmrtni ostaci 6.955 ubijenih. U Memorijalnom centru Srebrenica do sada su ukopane 6.643 žrtve genocida.\n\nMeđunarodni krivični sud za bivšu Jugoslaviju osudio je 20 osoba za zločine u Srebrenici, od toga sedam za genocid. Prema podacima Memorijalnog centra Srebrenica, Sud BiH za zločine u Srebrenici je osudio 26 osoba, od toga 13 za genocid.\n\nVodimo vas kroz arhivu Međunarodnog krivičnog suda za bivšu Jugoslaviju, dokumente, svjedočenja, kao i presude koje pokazuju razmjere najgoreg zločina počinjenog na evropskom tlu nakon Drugog svjetskog rata.",
                 published_at: ~N[2020-07-07 22:12:00],
                 author: "Una Čilić",
                 image:
                   "https://gdb.rferl.org/916D4F58-A347-4398-BD8D-C6800FCA51E7_w800_h450.jpg",
                 url:
                   "https://www.slobodnaevropa.org/a/srebrenica-dokumentovani-genocid/30713005.html"
               },
               %{
                 original_id: "30711830",
                 title: "Suljagić: Ubijanje Srebrenice počelo je 1992. godine",
                 description:
                   "Zbog čega je značajna memorijalizacija, izložba ličnih predmeta ubijenih i video svjedočanstva djece koja su preživjela rat u Srebrenici odgovara direktor Memorijalnog centra Srebrenica Potočari Emir Suljagić u razgovoru za TV Liberty RSE.",
                 published_at: ~N[2020-07-07 17:58:26],
                 author: "Marija Arnautović",
                 image:
                   "https://gdb.rferl.org/268ffb22-5b04-45c3-a6e3-8e91ee25756d_tv_w800_h450.jpg",
                 url:
                   "https://www.slobodnaevropa.org/a/suljagic-ubijanje-srebrenice-je-pocelo-1992-godine/30711830.html"
               },
               %{
                 original_id: "30704364",
                 title: "Kurspahić: Čuvari i promotori istine o Srebrenici",
                 description:
                   "Memorijalni centar genocida u Srebrenici postaje respektabilna institucija za očuvanje i promociju u svijetu istine o genocidu s misijom prepoznavanja i suzbijanja negiranja genocida.",
                 published_at: ~N[2020-07-03 11:25:47],
                 author: nil,
                 image:
                   "https://gdb.rferl.org/94106506-375B-463D-A6A1-2C6B1EE833DD_w800_h450.jpg",
                 url:
                   "https://www.slobodnaevropa.org/a/kurspahi%c4%87-%c4%8duvari-i-promotori-istine-o-srebrenici/30704364.html"
               }
             ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/radio_slobodna_evropa_scraper/feed.xml")
  end
end
