defmodule PratiBa.Scrapers.ZurnalScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.ZurnalScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = ZurnalScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "23208",
                 title: "Russia imperils Bosnia-Herzegovina!",
                 description:
                   "Western leaders seek stability and security in the Western Balkans even while viewing several states as unprepared for EU membership. Putin is seeking Balkan allies or supplicants. This is where the economic and energy dimensions are most pronounced in corrupting, blackmailing, or bribing key officials",
                 published_at: ~N[2020-07-03 09:19:51],
                 author: nil,
                 image: "https://zurnal.info/upload/images/2020/Bugajski%201.jpg",
                 url: "https://zurnal.info/novost/23208/russia-imperils-bosnia-herzegovina"
               },
               %{
                 original_id: "23206",
                 title: "Profesor odbrane je komunalni inspektor, bravar brine o kriptozaštiti",
                 description:
                   "Dok su u privatnim firmama zbog korona virusa radnicima dijeljeni otkazi, u javnim ustanovama u Kantonu Sarajevu aktivno su vršena nova zapošljavanja. Samo u Službi za zapošljavanje KS od prvog aprila zaposleno je 18 osoba",
                 published_at: ~N[2020-07-02 17:27:06],
                 author: nil,
                 image: "https://zurnal.info/upload/images/afzzz_kzzz1_Fotor.jpg",
                 url:
                   "https://zurnal.info/novost/23206/profesor-odbrane-je-komunalni-inspektor-bravar-brine-o-kriptozastiti"
               }
             ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    ~s(
      <?xml version="1.0" encoding="utf-8"?>
      <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
          <title>Feed title</title>
          <link>https://zurnal.info/</link>
          <copyright>Copyright 2020" Promotim d.o.o.</copyright>
          <description>Promotim</description>
          <item>
            <title>Russia imperils Bosnia&#45;Herzegovina!</title>
            <pubDate>Fri, 03 Jul 2020 11:19:51 +0200</pubDate>
            <description>Western leaders seek stability and security in the Western Balkans even while viewing several states as unprepared for EU membership. Putin is seeking Balkan allies or supplicants. This is where the economic and energy dimensions are most pronounced in corrupting, blackmailing, or bribing key officials</description>
            <link>https://zurnal.info/novost/23208/russia-imperils-bosnia-herzegovina</link>
            <guid>https://zurnal.info/novost/23208/russia-imperils-bosnia-herzegovina</guid>
            <enclosure url="https://zurnal.info/upload/images/2020/Bugajski%201.jpg" type="image/jpeg" length="1"/>
          </item>
          <item>
            <title>Profesor odbrane je komunalni inspektor, bravar brine o kriptozaštiti</title>
            <pubDate>Thu, 02 Jul 2020 19:27:06 +0200</pubDate>
            <description>Dok su u privatnim firmama zbog korona virusa radnicima dijeljeni otkazi, u javnim ustanovama u Kantonu Sarajevu aktivno su vršena nova zapošljavanja. Samo u Službi za zapošljavanje KS od prvog aprila zaposleno je 18 osoba</description>
            <link>https://zurnal.info/novost/23206/profesor-odbrane-je-komunalni-inspektor-bravar-brine-o-kriptozastiti</link>
            <guid>https://zurnal.info/novost/23206/profesor-odbrane-je-komunalni-inspektor-bravar-brine-o-kriptozastiti</guid>
            <enclosure url="https://zurnal.info/upload/images/afzzz_kzzz1_Fotor.jpg" type="image/jpeg" length="345308"/>
          </item>
        </channel>
      </rss>
    )
  end
end
