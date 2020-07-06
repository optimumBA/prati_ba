defmodule PratiBa.Scrapers.N1ScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.N1Scraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end

      response = N1Scraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response
      assert [
        %{
          original_id: "a445641",
          title: "Krišto o izmjenama budžeta BiH: Predsjedništvo je prekršilo Zakon o finansiranju",
          description: "Zamjenica predsjedavajućeg Predstavničkog doma Parlamentarne skupštine BiH Borjana Krišto izjavila je da je u dnevni red sutrašnje sjednice Predstavničkog doma uvršteno razmatranje budžeta institucija BiH za ovu godinu, po hitnoj proceduri.",
          published_at: ~N[2020-07-06 13:32:00],
          author: nil,
          image: "https://ba.n1info.com/Thumbnail/247936/jpeg/D9VfXfMX4AAZmGQ.jpg-large.jpg",
          url: "http://ba.n1info.com/Vijesti/a445641/Kristo-o-izmjenama-budzeta-BiH-Predsjednistvo-je-prekrsilo-Zakon-o-finansiranju.html",
        },
        %{
          original_id: "a445639",
          title: "Kim Jong-un izdao naredbu o \"maksimalnoj pripravnosti\" protiv pandemije",
          description: "Glavne novine Sjeverne Koreje, Rodon Sinmun, pozvale su u nedjelju na provođenje naredbe lidera Kim Jong-un da zemlja izvrši \"maksimalnu pripravnost\" protiv pandemije koronavirusa.",
          published_at: ~N[2020-07-06 13:23:00],
          author: nil,
          image: "https://ba.n1info.com/Thumbnail/240994/jpeg/Kim-Jong-Un",
          url: "http://ba.n1info.com/Svijet/a445639/Kim-Jong-un-izdao-naredbu-o-maksimalnoj-pripravnosti-protiv-pandemije.html",
        }
      ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    ~s(
      <?xml version="1.0" encoding="utf-8"?>
      <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
        <channel>
          <title>Naslovna</title>
          <description />
          <link>http://ba.n1info.com</link>
          <atom:link rel="self" href="http://ba.n1info.com" type="application/rss+xml" />
          <item>
            <title>Serbian Court sentences Bosnian national to 10 years for war crimes</title>
            <image>https://ba.n1info.com/Thumbnail/130827/jpeg/visi-sud.jpg</image>
            <description>The War Crimes Chamber of the Belgrade High Court sentenced a Bosnian national Husein Mujanovic, on Monday, to ten years in prison by a first-instance verdict for war crimes against Serb civilians.</description>
            <link>http://ba.n1info.com/English/NEWS/a445643/Serbian-Court-sentences-Bosnian-national-to-10-years-for-war-crimes.html</link>
            <guid>http://ba.n1info.com/English/NEWS/a445643/Serbian-Court-sentences-Bosnian-national-to-10-years-for-war-crimes.html</guid>
            <pubDate>Mon, 06 Jul 2020 13:39:00 GMT</pubDate>
          </item>
          <item>
            <title>Krišto o izmjenama budžeta BiH: Predsjedništvo je prekršilo Zakon o finansiranju</title>
            <image>https://ba.n1info.com/Thumbnail/247936/jpeg/D9VfXfMX4AAZmGQ.jpg-large.jpg</image>
            <description>Zamjenica predsjedavajućeg Predstavničkog doma Parlamentarne skupštine BiH Borjana Krišto izjavila je da je u dnevni red sutrašnje sjednice Predstavničkog doma uvršteno razmatranje budžeta institucija BiH za ovu godinu, po hitnoj proceduri.</description>
            <link>http://ba.n1info.com/Vijesti/a445641/Kristo-o-izmjenama-budzeta-BiH-Predsjednistvo-je-prekrsilo-Zakon-o-finansiranju.html</link>
            <guid>http://ba.n1info.com/Vijesti/a445641/Kristo-o-izmjenama-budzeta-BiH-Predsjednistvo-je-prekrsilo-Zakon-o-finansiranju.html</guid>
            <pubDate>Mon, 06 Jul 2020 13:32:00 GMT</pubDate>
          </item>
          <item>
            <title>Kim Jong-un izdao naredbu o "maksimalnoj pripravnosti" protiv pandemije</title>
            <image>https://ba.n1info.com/Thumbnail/240994/jpeg/Kim-Jong-Un</image>
            <description>Glavne novine Sjeverne Koreje, Rodon Sinmun, pozvale su u nedjelju na provođenje naredbe lidera Kim Jong-un da zemlja izvrši "maksimalnu pripravnost" protiv pandemije koronavirusa.</description>
            <link>http://ba.n1info.com/Svijet/a445639/Kim-Jong-un-izdao-naredbu-o-maksimalnoj-pripravnosti-protiv-pandemije.html</link>
            <guid>http://ba.n1info.com/Svijet/a445639/Kim-Jong-un-izdao-naredbu-o-maksimalnoj-pripravnosti-protiv-pandemije.html</guid>
            <pubDate>Mon, 06 Jul 2020 13:23:00 GMT</pubDate>
          </item>
        </channel>
      </rss>
    )
  end
end
