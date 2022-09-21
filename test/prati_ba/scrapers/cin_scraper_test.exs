defmodule PratiBa.Scrapers.CinScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.CinScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = CinScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "1027985",
                 description:
                   "Federalno ministarstvo za pitanja boraca i invalida odbilo je dostaviti CIN-u izvještaje o trošenju novca datog za zapošljavanje putem boračkih zadruga, iako je Kantonalni sud u Sarajevu ranije presudio da je takva odluka nezakonita.The post Ministarstvo skriva podatke o trošenju boračkog novca appeared first on CIN.",
                 title: "Ministarstvo skriva podatke o trošenju boračkog novca",
                 published_at: ~N[2022-09-13 07:10:42],
                 author: nil,
                 image: nil,
                 url:
                   "https://cin.ba/ministarstvo-skriva-podatke-o-trosenju-borackog-novca/?utm_source=rss&utm_medium=rss&utm_campaign=ministarstvo-skriva-podatke-o-trosenju-borackog-novca"
               }
             ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/gradani-taksama-placali-stanove-za-sudije/",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url = "http://localhost:#{bypass.port}/gradani-taksama-placali-stanove-za-sudije/"

      article = %{
        original_id: "1018669",
        title: "Građani taksama plaćali stanove za sudije",
        description:
          "Trojica nekadašnjih sudija Općinskog suda u Lukavcu već 20 godina koriste stanove, nezakonito kupljene budžetskim novcem. Niko nije kažnjen jer je predmet zastario.",
        published_at: ~N[2020-07-06 08:32:08],
        author: nil,
        image: nil,
        url: article_url
      }

      response = CinScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "1018669",
               title: "Građani taksama plaćali stanove za sudije",
               description:
                 "Trojica nekadašnjih sudija Općinskog suda u Lukavcu već 20 godina koriste stanove, nezakonito kupljene budžetskim novcem. Niko nije kažnjen jer je predmet zastario.",
               published_at: ~N[2020-07-06 08:32:08],
               author: nil,
               image: "https://www.cin.ba/wp-content/uploads/2020/07/stanovi-za-sudije.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    ~s"""
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:wfw="http://wellformedweb.org/CommentAPI/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:sy="http://purl.org/rss/1.0/modules/syndication/" xmlns:slash="http://purl.org/rss/1.0/modules/slash/">

      <channel>
        <title>CIN</title>
        <atom:link href="https://www.cin.ba/feed/" rel="self" type="application/rss+xml" />
        <link>https://www.cin.ba</link>
        <description>vaš izvor informacija</description>
        <lastBuildDate>Tue, 07 Jul 2020 07:44:20 +0000</lastBuildDate>
        <language>hr-HR</language>
        <sy:updatePeriod>hourly</sy:updatePeriod>
        <sy:updateFrequency>1</sy:updateFrequency>
        <generator>https://wordpress.org/?v=4.9.8</generator>
        <item>
    <title>Ministarstvo skriva podatke o trošenju boračkog novca</title>
    <link>https://cin.ba/ministarstvo-skriva-podatke-o-trosenju-borackog-novca/?utm_source=rss&#038;utm_medium=rss&#038;utm_campaign=ministarstvo-skriva-podatke-o-trosenju-borackog-novca</link>
    	<comments>https://cin.ba/ministarstvo-skriva-podatke-o-trosenju-borackog-novca/#respond</comments>

    <dc:creator><![CDATA[Centar za istraživačko novinarstvo (CIN)]]></dc:creator>
    <pubDate>Tue, 13 Sep 2022 07:10:42 +0000</pubDate>
    <category><![CDATA[Vijesti]]></category>
    <category><![CDATA[kantonalni sud u sarajevu]]></category>
    <category><![CDATA[boračke zadruge]]></category>
    <category><![CDATA[federalno ministarstvo za pitanje boraca i invalida]]></category>
    <category><![CDATA[trošenje novca]]></category>
    <category><![CDATA[nezakonito trošenje novca]]></category>
    <guid isPermaLink="false">https://cin.ba/?p=1027985</guid>

    	<description><![CDATA[<p>Federalno ministarstvo za pitanja boraca i invalida odbilo je dostaviti CIN-u izvještaje o trošenju novca datog za zapošljavanje putem boračkih zadruga, iako je Kantonalni sud u Sarajevu ranije presudio da je takva odluka nezakonita.</p>
    <p>The post <a rel="nofollow" href="https://cin.ba/ministarstvo-skriva-podatke-o-trosenju-borackog-novca/">Ministarstvo skriva podatke o trošenju boračkog novca</a> appeared first on <a rel="nofollow" href="https://cin.ba">CIN</a>.</p>
    ]]></description>

    </item>
      </channel>
    </rss>
    """
  end

  defp article_payload do
    File.read!("test/support/payloads/cin_scraper/article.html")
  end
end
