defmodule PratiBa.Scrapers.ZurnalScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.ZurnalScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = ZurnalScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert %{
               author: nil,
               description:
                 "Ministri u Vladi HNK sredstva za poticaje u privredi u proteklim\n                                godinama dijelili su članovima svojih porodica. Pritom, dio sredstava odobren je\n                                posebnim odlukama Vlade HNK i to iz fonda za hitne slučajeve",
               image: nil,
               original_id: "25312",
               published_at: nil,
               title:
                 "FUP IZUZEO DOKUMENTACIJU: Ministar Željko Laketić novac za\n                                hitne slučajeve dodijelio vlastitoj sestri!",
               url:
                 "https://zurnal.info/clanak/ministar-zeljko-laketic-novac-za-hitne-slucajeve-dodijelio-vlastitoj-sestri/25312"
             } = Enum.at(articles, 0)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/clanak/ministar-zeljko-laketic-novac-za-hitne-slucajeve-dodijelio-vlastitoj-sestri/25312",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/clanak/ministar-zeljko-laketic-novac-za-hitne-slucajeve-dodijelio-vlastitoj-sestri/25312"

      article = %{
        author: nil,
        description:
          "Ministri u Vladi HNK sredstva za poticaje u privredi u proteklim\n                                godinama dijelili su članovima svojih porodica. Pritom, dio sredstava odobren je\n                                posebnim odlukama Vlade HNK i to iz fonda za hitne slučajeve",
        image: nil,
        original_id: "25312",
        published_at: nil,
        title:
          "FUP IZUZEO DOKUMENTACIJU: Ministar Željko Laketić novac za\n hitne slučajeve dodijelio vlastitoj sestri!",
        url: article_url
      }

      response = ZurnalScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               author: nil,
               description:
                 "Ministri u Vladi HNK sredstva za poticaje u privredi u proteklim\n                                godinama dijelili su članovima svojih porodica. Pritom, dio sredstava odobren je\n                                posebnim odlukama Vlade HNK i to iz fonda za hitne slučajeve",
               image:
                 "https://zurnal.info/img/s/850x567/upload/images/article/25312/1e983b4163de9acad5def2c5a7b72669.jpg",
               original_id: "25312",
               published_at: ~N[2022-09-19 15:00:00],
               title:
                 "FUP IZUZEO DOKUMENTACIJU: Ministar Željko Laketić novac za\n hitne slučajeve dodijelio vlastitoj sestri!",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/zurnal_scraper/articles.html")
  end

  defp article_payload do
    File.read!("test/support/payloads/zurnal_scraper/article.html")
  end
end
