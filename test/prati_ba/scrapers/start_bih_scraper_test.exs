defmodule PratiBa.Scrapers.StartBihScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.StartBihScraper

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = StartBihScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 10

      assert %{
               original_id: "191193",
               title:
                 "1 / 1 Magoda: “Kroz podršku sportu nastojimo ojačati pozitivan imidž Sarajeva”",
               description: nil,
               published_at: nil,
               author: nil,
               image: nil,
               url:
                 "https://startbih.ba/clanak/1-1-magoda-kroz-podrsku-sportu-nastojimo-ojacati-pozitivan-imidz-sarajeva/191193"
             } = Enum.at(articles, 0)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/clanak/1-1-magoda-kroz-podrsku-sportu-nastojimo-ojacati-pozitivan-imidz-sarajeva/191193",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/clanak/1-1-magoda-kroz-podrsku-sportu-nastojimo-ojacati-pozitivan-imidz-sarajeva/191193"

      article = %{
        original_id: "191193",
        title: "1 / 1 Magoda: “Kroz podršku sportu nastojimo ojačati pozitivan imidž Sarajeva”",
        description: nil,
        published_at: nil,
        author: nil,
        image: nil,
        url: article_url
      }

      response = StartBihScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "191193",
               title:
                 "1 / 1 Magoda: “Kroz podršku sportu nastojimo ojačati pozitivan imidž Sarajeva”",
               description: nil,
               published_at: ~N[2022-08-29 14:40:00],
               author: nil,
               image:
                 "https://cdn.startbih.ba/articles/2022/08/29/560x410/301716529-3224200471130310-9200561889991231163-n_1.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/start_bih_scraper/articles.html")
  end

  defp article_payload do
    File.read!("test/support/payloads/start_bih_scraper/articles.html")
  end
end
