defmodule PratiBa.Scrapers.FaceScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.FaceScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = FaceScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 40

      assert %{
               original_id: "61831",
               title:
                 "Kineska regija upozorava: U jednoj bolnici prijavljen slučaj bolesti koja je u srednjem vijeku pokosila pola Evrope (VIDEO)",
               description: nil,
               published_at: nil,
               author: nil,
               image: nil,
               url:
                 "https://www.face.ba/vijesti/svijet/kineska-regija-upozorava-u-jednoj-bolnici-prijavljen-slucaj-bolesti-koja-je-u-srednjem-vijeku-pokosila-pola-europe-video/61831"
             } = Enum.at(articles, 0)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/vijesti/svijet/kineska-regija-upozorava-u-jednoj-bolnici-prijavljen-slucaj-bolesti-koja-je-u-srednjem-vijeku-pokosila-pola-europe-video/61831",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/vijesti/svijet/kineska-regija-upozorava-u-jednoj-bolnici-prijavljen-slucaj-bolesti-koja-je-u-srednjem-vijeku-pokosila-pola-europe-video/61831"

      article = %{
        original_id: "61831",
        title:
          "Kineska regija upozorava: U jednoj bolnici prijavljen slučaj bolesti koja je u srednjem vijeku pokosila pola Evrope (VIDEO)",
        description: nil,
        published_at: nil,
        author: nil,
        image: nil,
        url: article_url
      }

      response = FaceScraper.article_details(article)



      assert {:ok, article} = response

      assert %{
               original_id: "61831",
               title:
                 "Kineska regija upozorava: U jednoj bolnici prijavljen slučaj bolesti koja je u srednjem vijeku pokosila pola Evrope (VIDEO)",
               description:
                 "Mongolija je stavila regiju Hovd u karantenu nakon što su otkrivena dva slučaja bubonske kuge, bolesti koja je u srednjem vijeku odnijela milione života",
               published_at: ~N[2020-07-06 21:14:00],
               author: nil,
               image: "https://storage.face.ba/article/61831/1200x628/1268370.jpeg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/face_scraper/articles.html")
  end

  defp article_payload do
    File.read!("test/support/payloads/face_scraper/article.html")
  end
end
