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
                 original_id: "1018669",
                 title: "Građani taksama plaćali stanove za sudije",
                 description:
                   "Trojica nekadašnjih sudija Općinskog suda u Lukavcu već 20 godina koriste stanove, nezakonito kupljene budžetskim novcem. Niko nije kažnjen jer je predmet zastario.",
                 published_at: ~N[2020-07-06 08:32:08],
                 author: nil,
                 image: nil,
                 url: "https://www.cin.ba/gradani-taksama-placali-stanove-za-sudije/"
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
    ~s(
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
            <title>Građani taksama plaćali stanove za sudije</title>
            <link>https://www.cin.ba/gradani-taksama-placali-stanove-za-sudije/</link>
            <pubDate>Mon, 06 Jul 2020 08:32:08 +0000</pubDate>
            <dc:creator>
              <![CDATA[CIN]]>
            </dc:creator>
            <category>
              <![CDATA[Pravosuđe]]>
            </category>
            <category>
              <![CDATA[Korupcija]]>
            </category>
            <category>
              <![CDATA[sudije]]>
            </category>

            <guid isPermaLink="false">https://www.cin.ba/?p=1018669</guid>
            <description>
              <![CDATA[Trojica nekadašnjih sudija Općinskog suda u Lukavcu već 20 godina koriste stanove, nezakonito kupljene budžetskim novcem. Niko nije kažnjen jer je predmet zastario.]]>
            </description>
          </item>
        </channel>
      </rss>
    )
  end

  defp article_payload do
    File.read!("test/support/payloads/cin_scraper/article.html")
  end
end
