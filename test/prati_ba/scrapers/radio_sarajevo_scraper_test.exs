defmodule PratiBa.Scrapers.RadioSarajevoScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.RadioSarajevoScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = RadioSarajevoScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 author: "RSA",
                 description: nil,
                 image:
                   "https://storage.radiosarajevo.ba/article/468944/871x540/skodaenyaq-radiosarajevo-001.jpg?v1663174544",
                 original_id: "468944",
                 published_at: ~N[2022-09-14 17:05:00],
                 title:
                   "Škoda Enyaq iV predstavljena u Sarajevu: Potpuno električni SUV vrhunskih karakteristika",
                 url:
                   "https://radiosarajevo.ba/auto-moto/noviteti/skoda-enyaq-iv-predstavljena-u-sarajevu-potpuno-elektricni-suv/468944"
               },
               %{
                 author: "RSA",
                 description: nil,
                 image:
                   "https://storage.radiosarajevo.ba/article/468950/871x540/mikrofon-1.jpg?v1663164991",
                 original_id: "468950",
                 published_at: ~N[2022-09-14 14:31:00],
                 title: "Obaveze elektronskih medija prilikom praćenja predizbornih aktivnosti",
                 url:
                   "https://radiosarajevo.ba/vijesti/bosna-i-hercegovina/obaveze-elektronskih-medija-prilikom-pracenja-predizbornih-aktivnosti/468950"
               }
             ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    ~s(
      <?xml version="1.0" encoding="UTF-8" ?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title type="text">RADIO SARAJEVO RSS</title>
        <subtitle type="html"><![CDATA[RADIO SARAJEVO RSS]]></subtitle>
        <link href="https://radiosarajevo.ba/rss"></link>
        <id>https://radiosarajevo.ba/rss</id>
        <link rel="alternate" type="text/html" href="https://radiosarajevo.ba/rss" ></link>
        <link rel="self" type="application/atom+xml" href="https://radiosarajevo.ba/rss" ></link>
        <logo>https://radiosarajevo.ba//build/img/logo-s.png</logo>
        <updated>2020-03-04T11:32:22+01:00</updated>
        <entry>
        <author>
        <name>RSA</name>
        </author>
        <title type="text">
        <![CDATA[ Škoda Enyaq iV predstavljena u Sarajevu: Potpuno električni SUV vrhunskih karakteristika ]]>
        </title>
        <link rel="alternate" type="text/html" href="https://radiosarajevo.ba/auto-moto/noviteti/skoda-enyaq-iv-predstavljena-u-sarajevu-potpuno-elektricni-suv/468944"/>
        <id>https://radiosarajevo.ba/auto-moto/noviteti/skoda-enyaq-iv-predstavljena-u-sarajevu-potpuno-elektricni-suv/468944</id>
        <summary type="html">
        <![CDATA[ <img src="https://storage.radiosarajevo.ba/article/468944/871x540/skodaenyaq-radiosarajevo-001.jpg?v1663174544" alt="" height="66" width="90" align="left" hspace="6" /> ]]>
        </summary>
        <content type="html">
        <![CDATA[ ]]>
        </content>
        <updated>Wed, 14 Sep 2022 19:05:00 +0200</updated>
        </entry>
        <entry>
        <author>
        <name>RSA</name>
        </author>
        <title type="text">
        <![CDATA[ Obaveze elektronskih medija prilikom praćenja predizbornih aktivnosti ]]>
        </title>
        <link rel="alternate" type="text/html" href="https://radiosarajevo.ba/vijesti/bosna-i-hercegovina/obaveze-elektronskih-medija-prilikom-pracenja-predizbornih-aktivnosti/468950"/>
        <id>https://radiosarajevo.ba/vijesti/bosna-i-hercegovina/obaveze-elektronskih-medija-prilikom-pracenja-predizbornih-aktivnosti/468950</id>
        <summary type="html">
        <![CDATA[ <img src="https://storage.radiosarajevo.ba/article/468950/871x540/mikrofon-1.jpg?v1663164991" alt="" height="66" width="90" align="left" hspace="6" /> ]]>
        </summary>
        <content type="html">
        <![CDATA[ ]]>
        </content>
        <updated>Wed, 14 Sep 2022 16:31:00 +0200</updated>
        </entry>
      </feed>
    )
  end
end
