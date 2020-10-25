defmodule PratiBa.Scrapers.RaskrinkavanjeScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.RaskrinkavanjeScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = RaskrinkavanjeScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 12

      assert %{
               original_id: "slika-para-koji-se-ljubi-na-ulici-nije-nastala-u-beogradu",
               title: "Slika para koji se ljubi na ulici nije nastala u Beogradu",
               description: nil,
               published_at: ~N[2020-07-10 00:00:00],
               author: nil,
               image: nil,
               url:
                 "https://raskrinkavanje.ba/analiza/slika-para-koji-se-ljubi-na-ulici-nije-nastala-u-beogradu"
             } = Enum.at(articles, 0)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/analiza/slika-para-koji-se-ljubi-na-ulici-nije-nastala-u-beogradu",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/analiza/slika-para-koji-se-ljubi-na-ulici-nije-nastala-u-beogradu"

      article = %{
        original_id: "slika-para-koji-se-ljubi-na-ulici-nije-nastala-u-beogradu",
        title: "Slika para koji se ljubi na ulici nije nastala u Beogradu",
        description: nil,
        published_at: ~N[2020-07-10 00:00:00],
        author: nil,
        image: nil,
        url: article_url
      }

      response = RaskrinkavanjeScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "slika-para-koji-se-ljubi-na-ulici-nije-nastala-u-beogradu",
               title: "Slika para koji se ljubi na ulici nije nastala u Beogradu",
               description: nil,
               published_at: ~N[2020-07-10 00:00:00],
               author: nil,
               image:
                 "https://raskrinkavanje.ba/photos/shares/thumbs_labeled/slika-para-koji-se-ljubi-na-ulici-nije-nastala-u-beogradu.png",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/raskrinkavanje_scraper/articles.html")
  end

  defp article_payload do
    File.read!("test/support/payloads/raskrinkavanje_scraper/article.html")
  end
end
