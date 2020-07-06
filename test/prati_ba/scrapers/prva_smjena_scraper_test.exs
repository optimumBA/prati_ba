defmodule PratiBa.Scrapers.PrvaSmjenaScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.PrvaSmjenaScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = PrvaSmjenaScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "1773",
                 title:
                   "Milorad Dodik brani Fadila Novalića: Niko ne bi trebao odgovarati za nabavku u ekstremno teškim uvjetima",
                 description:
                   "Komentirajući odgovor Bosne i Hercegovine na pandemiju korona virusa, Milorad Dodik je kazao za N1 kako BiH čini sve što i druge zemlje te naglasio kako taj period ne bi...",
                 published_at: ~N[2020-07-02 16:37:03],
                 author: nil,
                 image: nil,
                 url:
                   "http://prvasmjena.com/milorad-dodik-brani-fadila-novalica-niko-ne-bi-trebao-odgovarati-za-nabavku-u-ekstremno-teskim-uvjetima/"
               },
               %{
                 original_id: "1771",
                 title: "Komšić odgovorio: Jedan čovjek ne može biti ministar u više kantona",
                 description:
                   "Banjalučka ATV je danas objavila kako je Demokratska fronta kandidovala Čedomira Jovanovića za funkciju ministra u više kantolanih vlada. – Između ostalih i za ministra obrazovanja USК, objavila je ATV....",
                 published_at: ~N[2020-07-02 10:30:00],
                 author: nil,
                 image: nil,
                 url:
                   "http://prvasmjena.com/komsic-odgovorio-jedan-covjek-ne-moze-biti-ministar-u-vise-kantona/"
               }
             ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/milorad-dodik-brani-fadila-novalica-niko-ne-bi-trebao-odgovarati-za-nabavku-u-ekstremno-teskim-uvjetima/",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/milorad-dodik-brani-fadila-novalica-niko-ne-bi-trebao-odgovarati-za-nabavku-u-ekstremno-teskim-uvjetima/"

      article = %{
        original_id: "1773",
        title:
          "Milorad Dodik brani Fadila Novalića: Niko ne bi trebao odgovarati za nabavku u ekstremno teškim uvjetima",
        description:
          "Komentirajući odgovor Bosne i Hercegovine na pandemiju korona virusa, Milorad Dodik je kazao za N1 kako BiH čini sve što i druge zemlje te naglasio kako taj period ne bi...",
        published_at: ~N[2020-07-02 16:37:03],
        author: nil,
        image: nil,
        url: article_url
      }

      response = PrvaSmjenaScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "1773",
               title:
                 "Milorad Dodik brani Fadila Novalića: Niko ne bi trebao odgovarati za nabavku u ekstremno teškim uvjetima",
               description:
                 "Komentirajući odgovor Bosne i Hercegovine na pandemiju korona virusa, Milorad Dodik je kazao za N1 kako BiH čini sve što i druge zemlje te naglasio kako taj period ne bi...",
               published_at: ~N[2020-07-02 16:37:03],
               author: nil,
               image: "http://prvasmjena.com/wp-content/uploads/2020/07/bake-dodo.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    ~s(
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:wfw="http://wellformedweb.org/CommentAPI/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:sy="http://purl.org/rss/1.0/modules/syndication/" xmlns:slash="http://purl.org/rss/1.0/modules/slash/">

        <channel>
          <title>Prva Smjena</title>
          <atom:link href="http://prvasmjena.com/feed/" rel="self" type="application/rss+xml" />
          <link>http://prvasmjena.com</link>
          <description>Portal za kritički proboj</description>
          <lastBuildDate>Thu, 02 Jul 2020 16:37:03 +0000</lastBuildDate>
          <language>en-US</language>
          <sy:updatePeriod>hourly</sy:updatePeriod>
          <sy:updateFrequency>
        1	</sy:updateFrequency>
          <generator>https://wordpress.org/?v=5.3.4</generator>

          <image>
            <url>http://prvasmjena.com/wp-content/uploads/2018/03/favicon.png</url>
            <title>Prva Smjena</title>
            <link>http://prvasmjena.com</link>
            <width>32</width>
            <height>32</height>
          </image>
          <item>
            <title>Milorad Dodik brani Fadila Novalića: Niko ne bi trebao odgovarati za nabavku u ekstremno teškim uvjetima</title>
            <link>http://prvasmjena.com/milorad-dodik-brani-fadila-novalica-niko-ne-bi-trebao-odgovarati-za-nabavku-u-ekstremno-teskim-uvjetima/</link>
            <pubDate>Thu, 02 Jul 2020 16:37:03 +0000</pubDate>
            <dc:creator>
              <![CDATA[Redakcija]]>
            </dc:creator>
            <category>
              <![CDATA[Vijesti]]>
            </category>

            <guid isPermaLink="false">http://prvasmjena.com/?p=1773</guid>
            <description>
              <![CDATA[Komentirajući odgovor Bosne i Hercegovine na pandemiju korona virusa, Milorad Dodik je kazao za N1 kako BiH čini sve što i druge zemlje te naglasio kako taj period ne bi...]]>
            </description>
            <content:encoded>
              <![CDATA[<p class="story-lead">Komentirajući odgovor Bosne i Hercegovine na pandemiju korona virusa, Milorad Dodik je kazao za N1 kako BiH čini sve što i druge zemlje te naglasio kako taj period ne bi trebao biti predmet istraga vezano za javne nabavke medicinske opreme s obzirom da su bili ekstremno teški uvjeti za nabavku iste.</p>
      <p>&#8211; Očigledno je da nema medicinskog odgovora na ovu pandemiju. Ona se zadržala i širi mimo svega što su govorili u martu &#8211; kada dođu topliji dani da će na to utjecati, ali ono se povećalo i u tom pogledu važna je činjenica da to nije onog intenziteta što je bilo ranije. Ali povećava se broj zaraženih i onih kojima treba intenzivna njega. RS je osigurala sasvim dovoljan broj respiratora za ekstremno tešku situaciju koja nije ni na vidiku i drugih materijala i opreme. Vjerujem da je tako i u FBiH. Neki pokušavaju da za vrijeme nabavke koja je bila specifična naprave slučajeve i u FBiH i RS-u na način koji je populistički, da se locira odgovornost za ekstremno teške uslove u kojima su se nalazile ekipe koje su nabavljale respiratore i opremu. Jedina adresa bila je Kina i nismo se mogli nositi s velikom konkurencijom. Sam Njujork u jednom trenutku je  zatražio milion respiratora, a mi 100. To govori gdje smo mi &#8211; rekao je Dodik.</p>
      <p>Istakao je kako taj period ne treba biti predmet istraga i da će se pokazati &#8220;da ljudi nisu prekršili procedure ni u FBiH ni u RS-u&#8221;.</p>
      <p>&#8211; Ako je neko htio privesti premijera, nije trebao za dan da ga pusti već da to provede do kraja što pokazuje da nije bilo jasnih podataka o tome da li jeste ili nije. Ja jesam za to da se utvrdi odgovornost i protiv svih kojih se bave malverzacijama, ali ne trebaju da odgovaraju za ekstremno teške uslove nabavke. Lako je bilo sjediti u kućama i čekati vrijeme da dignete galamu, a ne raditi ništa. Sam Novalić i oni koji su radili na tome mogu svjedočiti koliko je bilo teško, a mogu i ja sam &#8211; kazao je Dodik.</p>
      ]]>
            </content:encoded>
          </item>
          <item>
            <title>Komšić odgovorio: Jedan čovjek ne može biti ministar u više kantona</title>
            <link>http://prvasmjena.com/komsic-odgovorio-jedan-covjek-ne-moze-biti-ministar-u-vise-kantona/</link>
            <pubDate>Thu, 02 Jul 2020 10:30:00 +0000</pubDate>
            <dc:creator>
              <![CDATA[Redakcija]]>
            </dc:creator>
            <category>
              <![CDATA[Vijesti]]>
            </category>

            <guid isPermaLink="false">http://prvasmjena.com/?p=1771</guid>
            <description>
              <![CDATA[Banjalučka ATV je danas objavila kako je Demokratska fronta kandidovala Čedomira Jovanovića za funkciju ministra u više kantolanih vlada. &#8211; Između ostalih i za ministra obrazovanja USК, objavila je ATV....]]>
            </description>
            <content:encoded>
              <![CDATA[<p>Banjalučka ATV je danas objavila kako je Demokratska fronta kandidovala Čedomira Jovanovića za funkciju ministra u više kantolanih vlada.</p>
      <p>&#8211; Između ostalih i za ministra obrazovanja USК, objavila je ATV. U objavi se dodaj da je Jovanović, koji je ujedno i savjetnik lidera DF-a i člana Predsjedništva BiH Željka Komšića kandidat za pozicije na kojima je zbog konstitutivnosti potreban Srbin.</p>
      <p>Na ove napise reagirao je Komšićev kabinet.</p>
      <p>&#8211; Radi se o kvazinovinarskoj gluposti godine. Naprosto se isčuđavamo nad konstrukcijom novinara ATV-a, koja glasi; „za funkciju ministra u više kantonalnih vlada“. Niko ne može biti na funkciji ministra u više kantonalnih vlada“, rečeno iz kabineta člana Predsjedništva BiH Željka Komšića.</p>
      ]]>
            </content:encoded>
          </item>
        </channel>
      </rss>
    )
  end

  defp article_payload do
    File.read!("test/support/payloads/prva_smjena_scraper/article.html")
  end
end
