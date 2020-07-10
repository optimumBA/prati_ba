defmodule PratiBa.Scrapers.FokusScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.FokusScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = FokusScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "1816318",
                 title:
                   "Sedmomjesečni Vinko nakon teških operacija uspješno završio liječenje u Turskoj (FOTO)",
                 description: nil,
                 published_at: ~N[2020-07-10 14:39:38],
                 author: nil,
                 image: nil,
                 url:
                   "https://www.fokus.ba/vijesti/bih/sedmomjesecni-vinko-nakon-teskih-operacija-uspjesno-zavrsio-lijecenje-u-turskoj-foto/1816318/"
               }
             ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/vijesti/bih/sedmomjesecni-vinko-nakon-teskih-operacija-uspjesno-zavrsio-lijecenje-u-turskoj-foto/1816318/",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/vijesti/bih/sedmomjesecni-vinko-nakon-teskih-operacija-uspjesno-zavrsio-lijecenje-u-turskoj-foto/1816318/"

      article = %{
        original_id: "1816318",
        title:
          "Sedmomjesečni Vinko nakon teških operacija uspješno završio liječenje u Turskoj (FOTO)",
        description: nil,
        published_at: ~N[2020-07-10 14:39:38],
        author: nil,
        image: nil,
        url: article_url
      }

      response = FokusScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "1816318",
               title:
                 "Sedmomjesečni Vinko nakon teških operacija uspješno završio liječenje u Turskoj (FOTO)",
               description: nil,
               published_at: ~N[2020-07-10 14:39:38],
               author: nil,
               image: "https://www.fokus.ba/wp-content/uploads/2020/07/vinko-1.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/fokus_scraper/feed.xml")
  end

  defp article_payload do
    File.read!("test/support/payloads/fokus_scraper/article.html")
  end
end
