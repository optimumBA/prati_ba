defmodule PratiBa.Scrapers.SlobodnaBosnaScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.SlobodnaBosnaScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = SlobodnaBosnaScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "161898",
                 title:
                   "DOGOVOR VISI U ZRAKU?: Izetbegović i Čović stigli na sastanak kod Dodika u Istočno Sarajevo",
                 description: nil,
                 published_at: ~N[2020-07-07 11:30:43],
                 author: nil,
                 image: nil,
                 url:
                   "http://www.slobodna-bosna.ba/vijest/161898/dogovor_visi_u_zraku_izetbegovic_i_chovic_stigli_na_sastanak_kod_dodika_u_istochno_sarajevo.html"
               },
               %{
                 original_id: "161897",
                 title:
                   "PRESUDA MUJANOVIĆU OPASNO UGROZILA DIPLOMATSKE ODNOSE: Ambasadorica BiH u Srbiji pozvana na hitne konsultacije u sjedište Ministarstva vanjskih poslova",
                 description: nil,
                 published_at: ~N[2020-07-07 11:18:03],
                 author: nil,
                 image: nil,
                 url:
                   "http://www.slobodna-bosna.ba/vijest/161897/presuda_mujanovicu_opasno_ugrozila_diplomatske_odnose_ambasadorica_bih_u_srbiji_pozvana_na_hitne_konsultacije_u_sjediste_ministarstva_vanjskih_poslova.html"
               }
             ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/vijest/161898/dogovor_visi_u_zraku_izetbegovic_i_chovic_stigli_na_sastanak_kod_dodika_u_istochno_sarajevo.html",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/vijest/161898/dogovor_visi_u_zraku_izetbegovic_i_chovic_stigli_na_sastanak_kod_dodika_u_istochno_sarajevo.html"

      article = %{
        original_id: "161898",
        title:
          "DOGOVOR VISI U ZRAKU?: Izetbegović i Čović stigli na sastanak kod Dodika u Istočno Sarajevo",
        description: nil,
        published_at: ~N[2020-07-07 11:30:43],
        author: nil,
        image: nil,
        url: article_url
      }

      response = SlobodnaBosnaScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "161898",
               title:
                 "DOGOVOR VISI U ZRAKU?: Izetbegović i Čović stigli na sastanak kod Dodika u Istočno Sarajevo",
               description: nil,
               published_at: ~N[2020-07-07 11:30:43],
               author: nil,
               image: "http://www.slobodna-bosna.ba/img/vijesti/2020/07/img_20200707_134908.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    ~s(
      <?xml version='1.0' encoding='utf-8'?>

      <rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:slash="http://purl.org/rss/1.0/modules/slash/">
        <channel>
          <title>Sve vijesti - RSS | Slobodna-Bosna.ba</title>
          <link>http://www.slobodna-bosna.ba/</link>
          <description>Slobodna Bosna - Nezavisni informativni portal</description>
          <lastBuildDate>Tue, 07 Jul 2020 13:54:35 +0200</lastBuildDate>
          <language>rs</language>

          <image>
            <title>Sve vijesti - RSS | Slobodna-Bosna.ba</title>
            <width>253</width>
            <height>40</height>
            <link>http://www.slobodna-bosna.ba/</link>
            <url>http://www.slobodna-bosna.ba/img/share/logo_slobodna-bosna_rss.jpg</url>
          </image>

          <item>
            <title>DOGOVOR VISI U ZRAKU?: Izetbegović i Čović stigli na sastanak kod Dodika u Istočno Sarajevo</title>
            <link>http://www.slobodna-bosna.ba/vijest/161898/dogovor_visi_u_zraku_izetbegovic_i_chovic_stigli_na_sastanak_kod_dodika_u_istochno_sarajevo.html</link>
            <pubDate>Tue, 07 Jul 2020 13:30:43 +0200</pubDate>
            <category>Politika</category>
            <content:encoded>
              <![CDATA[U Istočnom Sarajevu danas će biti održan sastanak predsjednika SNSD-a Milorada Dodika, HDZ-a Dragana Čovića i SDA Bakira Izetbegovića na kojem bi trebalo da bude riječi o imenovanjima i o Budžetu institucija Bosne i Hercegovine za ovu godinu.]]>
            </content:encoded>
          </item>

          <item>
            <title>PRESUDA MUJANOVIĆU OPASNO UGROZILA DIPLOMATSKE ODNOSE: Ambasadorica BiH u Srbiji pozvana na hitne konsultacije u sjedište Ministarstva vanjskih poslova</title>
            <link>http://www.slobodna-bosna.ba/vijest/161897/presuda_mujanovicu_opasno_ugrozila_diplomatske_odnose_ambasadorica_bih_u_srbiji_pozvana_na_hitne_konsultacije_u_sjediste_ministarstva_vanjskih_poslova.html</link>
            <pubDate>Tue, 07 Jul 2020 13:18:03 +0200</pubDate>
            <category>Politika</category>
            <content:encoded>
              <![CDATA[Zamjenica predsjedavajućeg Vijeća ministara Bosne i Hercegovine i ministrica vanjskih poslova naše zemlje dr. Bisera Turković, pozvala je danas na hitne konsultacije u sjedište Ministarstva vanjskih poslova Bosne i Hercegovine Aidu Smajić, rezidentnog ambasadora naše zemlje u Srbiji, saznaje portal Radiosarajavo.ba.]]>
            </content:encoded>
          </item>
        </channel>
      </rss>
    )
  end

  defp article_payload do
    File.read!("test/support/payloads/slobodna_bosna_scraper/article.html")
  end
end
