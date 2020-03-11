defmodule PratiBa.Scrapers.RadioSarajevoScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.RadioSarajevoScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end

      response = RadioSarajevoScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, [
        %{
          id: 369198,
          title: "Djevojčica koja se smijala bombama sa porodicom prešla u Tursku",
          description: nil,
          category: "Vijesti",
          published_at: ~N[2020-03-04 10:00:00],
          author: "Radiosarajevo.ba",
          image: %{
            url: "https://storage.radiosarajevo.ba/article/369198/871x540/otac_kcerka_sirija_granatiranje_igra_smijeh_prtscr.jpg",
            width: "871",
            height: "540",
            credit: nil,
          },
          url: "https://radiosarajevo.ba/vijesti/svijet/djevojcica-koja-se-smijala-bombama-sa-porodicom-presla-u-tursku/369198",
        },
        %{
          id: 369192,
          title: "Iskorijeniti korupciju, izliječiti zdravstvo",
          description: nil,
          category: "Vijesti",
          published_at: ~N[2020-03-04 08:48:00],
          author: "EU info centar",
          image: %{
            url: "https://storage.radiosarajevo.ba/article/369192/871x540/EUperiskop_1.jpg",
            width: "871",
            height: "540",
            credit: nil,
          },
          url: "https://radiosarajevo.ba/vijesti/euphoria/iskorijeniti-korupciju-izlijeciti-zdravstvo/369192",
        },
        %{
          id: 369087,
          title: "BiH prvi put u Diviziji A, direktnog prijenosa izvlačenja grupa neće biti?",
          description: nil,
          category: "Sport",
          published_at: ~N[2020-03-03 09:15:00],
          author: "A. S.",
          image: %{
            url: "https://storage.radiosarajevo.ba/article/369087/871x540/Bosnia_liganacija_mart2020.jpg",
            width: "871",
            height: "540",
            credit: nil,
          },
          url: "https://radiosarajevo.ba/sport/nogomet/sramotno-bih-prvi-put-u-diviziji-a-ali-nece-biti-direktnog-prijenosa-izvlacenja-grupa/369087",
        },
      ]} = response
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
            <name>Radiosarajevo.ba</name>
          </author>
          <title type="text"><![CDATA[Djevojčica koja se smijala bombama sa porodicom prešla u Tursku ]]></title>
          <link rel="alternate" type="text/html" href="https://radiosarajevo.ba/vijesti/svijet/djevojcica-koja-se-smijala-bombama-sa-porodicom-presla-u-tursku/369198"></link>
          <id>https://radiosarajevo.ba/vijesti/svijet/djevojcica-koja-se-smijala-bombama-sa-porodicom-presla-u-tursku/369198</id>
          <summary type="html"><![CDATA[<img src="https://storage.radiosarajevo.ba/article/369198/871x540/otac_kcerka_sirija_granatiranje_igra_smijeh_prtscr.jpg" height="66" width="90" align="left" hspace="6" /> ]]></summary>
          <content type="html"><![CDATA[]]></content>
          <updated>2020-03-04T11:00:00+01:00</updated>
        </entry>
        <entry>
          <author>
            <name>EU info centar</name>
          </author>
          <title type="text"><![CDATA[Iskorijeniti korupciju, izliječiti zdravstvo]]></title>
          <link rel="alternate" type="text/html" href="https://radiosarajevo.ba/vijesti/euphoria/iskorijeniti-korupciju-izlijeciti-zdravstvo/369192"></link>
          <id>https://radiosarajevo.ba/vijesti/euphoria/iskorijeniti-korupciju-izlijeciti-zdravstvo/369192</id>
          <summary type="html"><![CDATA[<img src="https://storage.radiosarajevo.ba/article/369192/871x540/EUperiskop_1.jpg" height="66" width="90" align="left" hspace="6" /> ]]></summary>
          <content type="html"><![CDATA[]]></content>
          <updated>2020-03-04T09:48:00+01:00</updated>
        </entry>
        <entry>
          <author>
            <name>A. S. </name>
          </author>
          <title type="text"><![CDATA[BiH prvi put u Diviziji A, direktnog prijenosa izvlačenja grupa neće biti?]]></title>
          <link rel="alternate" type="text/html" href="https://radiosarajevo.ba/sport/nogomet/sramotno-bih-prvi-put-u-diviziji-a-ali-nece-biti-direktnog-prijenosa-izvlacenja-grupa/369087"></link>
          <id>https://radiosarajevo.ba/sport/nogomet/sramotno-bih-prvi-put-u-diviziji-a-ali-nece-biti-direktnog-prijenosa-izvlacenja-grupa/369087</id>
          <summary type="html"><![CDATA[<img src="https://storage.radiosarajevo.ba/article/369087/871x540/Bosnia_liganacija_mart2020.jpg" height="66" width="90" align="left" hspace="6" /> ]]></summary>
          <content type="html"><![CDATA[]]></content>
          <updated>2020-03-03T10:15:00+01:00</updated>
        </entry>
      </feed>
    )
  end
end
