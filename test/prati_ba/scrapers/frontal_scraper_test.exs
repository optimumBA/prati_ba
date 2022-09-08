defmodule PratiBa.Scrapers.FrontalScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.FrontalScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = FrontalScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "108765",
                 title: "Dodik: Predložio sam da se Šmit proglasi personom non grata (VIDEO)",
                 description:
                   "Srpski član Predsjedništva BiH Milorad Dodik rekao je danas da je na vanrednoj sjednici Predsjedništva predložio da Kristijan Šmit bude proglašen personom non grata u BiH.",
                 published_at: ~N[2022-09-02 09:28:40],
                 author: nil,
                 image: "https://www.frontal.ba/upload/images/Fotografije%202/b_210829039.jpg",
                 url:
                   "https://www.frontal.ba/novost/108765/dodik-predlozio-sam-da-se-smit-proglasi-personom-non-grata-video"
               },
               %{
                 original_id: "108764",
                 title: "U Beogradu počeo Samit „Otvoreni Balkan“",
                 description:
                   "U Beogradu je počeo Samit u okviru inicijative \"Otvoreni Balkan\", kome prisustvuje, između ostalih, predsjedavajući Savjeta ministara BiH Zoran Tegeltija.",
                 published_at: ~N[2022-09-02 08:39:26],
                 author: nil,
                 image: "https://www.frontal.ba/upload/images/Fotografije%202/uhkoioto8iošz.jpg",
                 url:
                   "https://www.frontal.ba/novost/108764/-u-beogradu-poceo-samit-otvoreni-balkan"
               }
             ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    ~s"""
    <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
    <channel>
    <title>Frontal RSS Feed</title>
    <link>https://www.frontal.ba/</link>
    <copyright>Copyright 2022" Promotim d.o.o.</copyright>
    <description>Promotim</description>
    <item>
    <title>Dodik: Predložio sam da se Šmit proglasi personom non grata (VIDEO)</title>
    <pubDate>Fri, 02 Sep 2022 11:28:40 +0200</pubDate>
    <description>Srpski član Predsjedništva BiH Milorad Dodik rekao je danas da je na vanrednoj sjednici Predsjedništva predložio da Kristijan Šmit bude proglašen personom non grata u BiH.</description>
    <link>https://www.frontal.ba/novost/108765/dodik-predlozio-sam-da-se-smit-proglasi-personom-non-grata-video</link>
    <guid>https://www.frontal.ba/novost/108765/dodik-predlozio-sam-da-se-smit-proglasi-personom-non-grata-video</guid>
    <enclosure url="https://www.frontal.ba/upload/images/Fotografije%202/b_210829039.jpg" type="image/jpeg" length="1"/>
    </item>
    <item>
    <title> U Beogradu počeo Samit „Otvoreni Balkan“</title>
    <pubDate>Fri, 02 Sep 2022 10:39:26 +0200</pubDate>
    <description>U Beogradu je počeo Samit u okviru inicijative "Otvoreni Balkan", kome prisustvuje, između ostalih, predsjedavajući Savjeta ministara BiH Zoran Tegeltija.</description>
    <link>https://www.frontal.ba/novost/108764/-u-beogradu-poceo-samit-otvoreni-balkan</link>
    <guid>https://www.frontal.ba/novost/108764/-u-beogradu-poceo-samit-otvoreni-balkan</guid>
    <enclosure url="https://www.frontal.ba/upload/images/Fotografije%202/uhkoioto8iošz.jpg" type="image/jpeg" length="1"/>
    </item>
    </channel>
    </rss>
    """
  end
end
