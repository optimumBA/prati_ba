defmodule PratiBa.KlixScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.KlixScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end

      response = KlixScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, [
        %{
          id: 200303186,
          title: "Ove države ukinule su monarhiju i bile nemilosrdne prema nekadašnjim vladarima",
          description: "Kraljevi i carevi nekada su vladali brojnim zemljama, a ovi historijski događaji kriju se iza činjenice da su mnoge od njih prekinule vladavinu kraljevskih obitelji.",
          category: "Lifestyle",
          published_at: %DateTime{year: 2020, month: 3, day: 03, zone_abbr: "+01",
                                  hour: 17, minute: 39, second: 0, microsecond: {0, 0},
                                  utc_offset: 3600, std_offset: 0, time_zone: "Etc/GMT-1"},
          author: "DP",
          image: %{
            width: "850",
            url: "https://static.klix.ba/media/images/vijesti/b_200303186.jpg?v=2",
            credit: "Foto:Printskrin/youtube/ Timeline - World History Documentaries",
          },
          url: "https://www.klix.ba/lifestyle/ove-drzave-ukinule-su-monarhiju-i-bile-nemilosrdne-prema-nekadasnjim-vladarima/200303186",
        },
        %{
          id: 200303183,
          title: "Žrijeb grupa Lige nacija od 18 sati: Zmajevi čekaju protivnike u evropskoj eliti",
          description: "Nogometna reprezentacija Bosne i Hercegovine će danas saznati protivnike u Ligi nacija za sezonu 2020/2021.",
          category: "Nogomet",
          published_at: %DateTime{year: 2020, month: 3, day: 03, zone_abbr: "+01",
                                  hour: 17, minute: 30, second: 0, microsecond: {0, 0},
                                  utc_offset: 3600, std_offset: 0, time_zone: "Etc/GMT-1"},
          author: "E. B.",
          image: %{
            width: "850",
            url: "https://static.klix.ba/media/images/vijesti/b_200303183.jpg?v=1",
            credit: "Foto: EPA-EFE",
          },
          url: "https://www.klix.ba/sport/nogomet/zrijeb-grupa-lige-nacija-od-18-sati-zmajevi-cekaju-protivnike-u-evropskoj-eliti/200303183",
        },
        %{
          id: 200303191,
          title: "Asim Sarajlić: Izvinjavam se svima koje sam ugrozio, možda više neću biti ni delegat",
          description: "Glavni akter afere koja je zatresla SDA, ali i širu bh. javnost, Asim Sarajlić nakon današnje sjednice Kolegija SDA je kazao da se izvinjava svima koje je ugrozio svojim činjenjem ili ne činjenjem te dodao da život ide dalje. On je poručio da je njegova ostavka u stranci konačna te da možda više neće biti ni delegat u Domu naroda Parlamenta BiH.",
          category: "BiH",
          published_at: %DateTime{year: 2020, month: 3, day: 03, zone_abbr: "+01",
                                  hour: 17, minute: 29, second: 0, microsecond: {0, 0},
                                  utc_offset: 3600, std_offset: 0, time_zone: "Etc/GMT-1"},
          author: "A. B.",
          image: %{
            width: "850",
            url: "https://static.klix.ba/media/images/vijesti/b_200303191.jpg?v=1",
            credit: "Foto: D. S./Klix.ba",
          },
          url: "https://www.klix.ba/vijesti/bih/asim-sarajlic-izvinjavam-se-svima-koje-sam-ugrozio-mozda-vise-necu-biti-ni-delegat/200303191",
        }
      ]} = response
    end
  end

  defp articles_payload do
    ~s(
      <?xml version="1.0" encoding="UTF-8"?>
      <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
        <channel>
          <atom:link href="https://www.klix.ba/rss/svevijesti" rel="self" type="application/rss+xml" />
          <title>Klix.ba - RSS</title>
          <link>https://www.klix.ba/</link>
          <description>Sve vijesti sa portala Klix.ba</description>
          <language>bs-ba</language>
          <copyright>Klix.ba 2020</copyright>
          <pubDate>Tue, 03 Mar 2020 17:44:12 +0100</pubDate>
          <image>
            <title>Klix.ba - RSS</title>
            <url>https://www.klix.ba/images/logo.png</url>
            <link>https://www.klix.ba/</link>
          </image>
          <item>
            <title>Ove države ukinule su monarhiju i bile nemilosrdne prema nekadašnjim vladarima</title>
            <link>https://www.klix.ba/lifestyle/ove-drzave-ukinule-su-monarhiju-i-bile-nemilosrdne-prema-nekadasnjim-vladarima/200303186</link>
            <guid>https://www.klix.ba/lifestyle/ove-drzave-ukinule-su-monarhiju-i-bile-nemilosrdne-prema-nekadasnjim-vladarima/200303186</guid>
            <description><![CDATA[Kraljevi i carevi nekada su vladali brojnim zemljama, a ovi historijski događaji kriju se iza činjenice da su mnoge od njih prekinule vladavinu kraljevskih obitelji.]]></description>
            <category domain="https://www.klix.ba/lifestyle">Lifestyle</category>
            <pubDate>Tue, 03 Mar 2020 17:39:00 +0100</pubDate>
            <dc:creator>DP</dc:creator>
            <media:content width="850" url="https://static.klix.ba/media/images/vijesti/b_200303186.jpg?v=2">
              <media:credit scheme="urn:ebu">Foto:Printskrin/youtube/ Timeline - World History Documentaries</media:credit>
            </media:content>
          </item>
          <item>
            <title>Žrijeb grupa Lige nacija od 18 sati: Zmajevi čekaju protivnike u evropskoj eliti</title>
            <link>https://www.klix.ba/sport/nogomet/zrijeb-grupa-lige-nacija-od-18-sati-zmajevi-cekaju-protivnike-u-evropskoj-eliti/200303183</link>
            <guid>https://www.klix.ba/sport/nogomet/zrijeb-grupa-lige-nacija-od-18-sati-zmajevi-cekaju-protivnike-u-evropskoj-eliti/200303183</guid>
            <description><![CDATA[Nogometna reprezentacija Bosne i Hercegovine će danas saznati protivnike u Ligi nacija za sezonu 2020/2021.]]></description>
            <category domain="https://www.klix.ba/sport/nogomet">Nogomet</category>
            <pubDate>Tue, 03 Mar 2020 17:30:00 +0100</pubDate>
            <dc:creator>E. B.</dc:creator>
            <media:content width="850" url="https://static.klix.ba/media/images/vijesti/b_200303183.jpg?v=1">
              <media:credit scheme="urn:ebu">Foto: EPA-EFE</media:credit>
            </media:content>
          </item>
          <item>
            <title>Asim Sarajlić: Izvinjavam se svima koje sam ugrozio, možda više neću biti ni delegat</title>
            <link>https://www.klix.ba/vijesti/bih/asim-sarajlic-izvinjavam-se-svima-koje-sam-ugrozio-mozda-vise-necu-biti-ni-delegat/200303191</link>
            <guid>https://www.klix.ba/vijesti/bih/asim-sarajlic-izvinjavam-se-svima-koje-sam-ugrozio-mozda-vise-necu-biti-ni-delegat/200303191</guid>
            <description><![CDATA[Glavni akter afere koja je zatresla SDA, ali i širu bh. javnost, Asim Sarajlić nakon današnje sjednice Kolegija SDA je kazao da se izvinjava svima koje je ugrozio svojim činjenjem ili ne činjenjem te dodao da život ide dalje. On je poručio da je njegova ostavka u stranci konačna te da možda više neće biti ni delegat u Domu naroda Parlamenta BiH.]]></description>
            <category domain="https://www.klix.ba/vijesti/bih">BiH</category>
            <pubDate>Tue, 03 Mar 2020 17:29:00 +0100</pubDate>
            <dc:creator>A. B.</dc:creator>
            <media:content width="850" url="https://static.klix.ba/media/images/vijesti/b_200303191.jpg?v=1">
              <media:credit scheme="urn:ebu">Foto: D. S./Klix.ba</media:credit>
            </media:content>
          </item>
        </channel>
      </rss>
    )
  end
end
