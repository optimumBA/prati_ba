defmodule PratiBa.Scrapers.DwScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.DwScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = DwScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "54087065",
                 title: "Tenzije između Srbije i BiH zbog presude za ratni zločin",
                 description:
                   "Ministarstvo spoljnih poslova Bosne i Hercegovine uputilo je protestnu notu Srbiji nakon što je Husein Mujanović u Beogradu osuđen na deset godina zatvora za ratni zločin. Uslijedile su i reakcije iz Srbije.",
                 published_at: ~N[2020-07-08 08:58:00],
                 author: nil,
                 image: nil,
                 url:
                   "https://www.dw.com/bs/tenzije-izme%C4%91u-srbije-i-bih-zbog-presude-za-ratni-zlo%C4%8Din/a-54087065?maca=bos-rss-bos-all-1475-rdf"
               }
             ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/bs/tenzije-izme%C4%91u-srbije-i-bih-zbog-presude-za-ratni-zlo%C4%8Din/a-54087065",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/bs/tenzije-izme%C4%91u-srbije-i-bih-zbog-presude-za-ratni-zlo%C4%8Din/a-54087065?maca=bos-rss-bos-all-1475-rdf"

      article = %{
        original_id: "54087065",
        title: "Tenzije između Srbije i BiH zbog presude za ratni zločin",
        description:
          "Ministarstvo spoljnih poslova Bosne i Hercegovine uputilo je protestnu notu Srbiji nakon što je Husein Mujanović u Beogradu osuđen na deset godina zatvora za ratni zločin. Uslijedile su i reakcije iz Srbije.",
        published_at: ~N[2020-07-08 08:58:00],
        author: nil,
        image: nil,
        url: article_url
      }

      response = DwScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "54087065",
               title: "Tenzije između Srbije i BiH zbog presude za ratni zločin",
               description:
                 "Ministarstvo spoljnih poslova Bosne i Hercegovine uputilo je protestnu notu Srbiji nakon što je Husein Mujanović u Beogradu osuđen na deset godina zatvora za ratni zločin. Uslijedile su i reakcije iz Srbije.",
               published_at: ~N[2020-07-08 08:58:00],
               author: nil,
               image: "https://www.dw.com/image/54073578_304.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    ~s(
      <?xml version="1.0" encoding="UTF-8"?>
      <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:sy="http://purl.org/rss/modules/syndication/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:dwsyn="http://rss.dw.com/syndication/dwsyn/">
        <channel rdf:about="https://rss.dw.com/syndication/feeds/rss-bos-all.1475.rdf">
          <description>Bosnian Homepage</description>
          <link>https://www.dw.com/s-10037?maca=bos-rss-bos-all-1475-rdf</link>
          <title>DW-WORLD´s Bosnian Homepage</title>
          <sy:updatePeriod>hourly</sy:updatePeriod>
          <sy:updateFequency>4</sy:updateFequency>
          <sy:updateBase>2002-05-01T00:00:00Z</sy:updateBase>
          <dc:date>2020-07-08T09:41:48Z</dc:date>
          <image rdf:resource="https://rss.dw.com/images/DW-L-RGB_whitebg.png" />
          <items>
            <rdf:Seq>
              <rdf:li rdf:resource="https://www.dw.com/bs/tenzije-između-srbije-i-bih-zbog-presude-za-ratni-zločin/a-54087065?maca=bos-rss-bos-all-1475-rdf" />
            </rdf:Seq>
          </items>
        </channel>
        <image rdf:about="https://rss.dw.com/images/DW-L-RGB_whitebg.png">
          <url>https://rss.dw.com/images/DW-L-RGB_whitebg.png</url>
          <link>https://www.dw.com/s-10037?maca=bos-rss-bos-all-1475-rdf</link>
          <title>DW.COM</title>
          <description>News, Analysis and Service from Germany and Europe - in 30 Languages</description>
        </image>
        <item rdf:about="https://www.dw.com/bs/tenzije-između-srbije-i-bih-zbog-presude-za-ratni-zločin/a-54087065?maca=bos-rss-bos-all-1475-rdf">
          <title>Tenzije između Srbije i BiH zbog presude za ratni zločin</title>
          <link>https://www.dw.com/bs/tenzije-između-srbije-i-bih-zbog-presude-za-ratni-zločin/a-54087065?maca=bos-rss-bos-all-1475-rdf</link>
          <description>Ministarstvo spoljnih poslova Bosne i Hercegovine uputilo je protestnu notu Srbiji nakon što je Husein Mujanović u Beogradu osuđen na deset godina zatvora za ratni zločin. Uslijedile su i reakcije iz Srbije.</description>
          <dc:date>2020-07-08T08:58:00Z</dc:date>
          <dc:subject>Politika</dc:subject>
          <dc:language>bs</dc:language>
          <dwsyn:contentID>54087065</dwsyn:contentID>
        </item>
      </rdf:RDF>
    )
  end

  defp article_payload do
    File.read!("test/support/payloads/dw_scraper/article.html")
  end
end
