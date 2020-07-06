defmodule PratiBa.Scrapers.DnevniAvazScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.DnevniAvazScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end

      response = DnevniAvazScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response
      assert [
        %{
          original_id: "579853",
          title: "Parada i referendum koštali Rusiju više od pet milijardi dolara",
          description: "Parada i referendum koštali Rusiju više od pet milijardi dolara - Ruska vlada proglasila je dva dodatna neradna perioda kako bi održala Paradu pobjede i omogućila glasanje na referendumu, što je rusku privredu koštalo više od pet milijardi dolara, navode analitičari za \"The Moscow Times\"",
          published_at: ~N[2020-07-06 05:31:00],
          author: nil,
          image: "https://avaz.ba/media/2020/07/06/1286153/thumbs/873x400.jpg",
          url: "https://avaz.ba/globus/svijet/579853/parada-i-referendum-kostali-rusiju-vise-od-pet-milijardi-dolara",
        },
        %{
          original_id: "579852",
          title: "Danas isplata penzija za juni",
          description: "Danas isplata penzija za juni - Sukladno Zakonu o penzijskom i invalidskom osiguranju, penzije za mjesec juni bit će isplaćene danas preko Jedinstvenog računa trezora FBiH",
          published_at: ~N[2020-07-06 05:18:00],
          author: nil,
          image: "https://avaz.ba/media/2020/07/06/1286149/thumbs/873x400.jpg",
          url: "https://avaz.ba/vijesti/bih/579852/danas-isplata-penzija-za-juni",
        }
      ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    ~s(
      <?xml version="1.0" encoding="UTF-8"?>
      <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
        <channel>
          <atom:link href="https://avaz.ba/rss" rel="self" type="application/rss+xml" />
          <title>Avaz.ba - RSS</title>
          <link>http://www.avaz.ba/</link>
          <description>Najnovije iz kategorije najnovije sa portala Avaz.ba</description>
          <language>bs-ba</language>
          <copyright>Avaz.ba 2017</copyright>
          <pubDate>Mon, 06 Jul 2020 07:31:00 +0200</pubDate>
          <image>
            <title>Avaz.ba - RSS</title>
            <url>https://avaz.ba/media/2017/06/06/291441/thumbs/main_header_logo.png</url>
            <link>http://www.avaz.ba/</link>
          </image>
          <item>
            <title>Parada i referendum koštali Rusiju više od pet milijardi dolara</title>
            <link>https://avaz.ba/globus/svijet/579853/parada-i-referendum-kostali-rusiju-vise-od-pet-milijardi-dolara</link>
            <guid>https://avaz.ba/globus/svijet/579853/parada-i-referendum-kostali-rusiju-vise-od-pet-milijardi-dolara</guid>
            <description>
              <![CDATA[
                Parada i referendum koštali Rusiju više od pet milijardi dolara - Ruska vlada proglasila je dva dodatna neradna perioda kako bi održala Paradu pobjede i omogućila glasanje na referendumu, što je rusku privredu koštalo više od pet milijardi dolara, navode analitičari za "The Moscow Times"
              ]]>
            </description>
            <category domain="https://avaz.ba/globus/svijet">MOSKVA</category>
            <pubDate>Mon, 06 Jul 2020 07:31:00 +0200</pubDate>
            <dc:creator>Avaz.ba</dc:creator>
            <media:content width="873" url="https://avaz.ba/media/2020/07/06/1286153/thumbs/873x400.jpg">
              <media:credit scheme="urn:ebu">Neradni dani usred nedjelje zaustavili su privredu </media:credit>
            </media:content>
          </item>
          <item>
            <title>Danas isplata penzija za juni</title>
            <link>https://avaz.ba/vijesti/bih/579852/danas-isplata-penzija-za-juni</link>
            <guid>https://avaz.ba/vijesti/bih/579852/danas-isplata-penzija-za-juni</guid>
            <description>
              <![CDATA[
                Danas isplata penzija za juni - Sukladno Zakonu o penzijskom i invalidskom osiguranju, penzije za mjesec juni bit će isplaćene danas preko Jedinstvenog računa trezora FBiH
              ]]>
            </description>
            <category domain="https://avaz.ba/vijesti/bih">OSIGURANO 189 MILIONA KM</category>
            <pubDate>Mon, 06 Jul 2020 07:18:00 +0200</pubDate>
            <dc:creator>Avaz.ba</dc:creator>
            <media:content width="873" url="https://avaz.ba/media/2020/07/06/1286149/thumbs/873x400.jpg">
              <media:credit scheme="urn:ebu">Penziju za mjesec juni će primiti 426.194 korisnika</media:credit>
            </media:content>
          </item>
        </channel>
      </rss>
    )
  end
end
