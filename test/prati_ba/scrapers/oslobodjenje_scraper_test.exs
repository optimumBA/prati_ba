defmodule PratiBa.Scrapers.OslobodjenjeScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.OslobodjenjeScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = OslobodjenjeScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 original_id: "569244",
                 title: "Na današnji dan - 8. juli",
                 description: nil,
                 published_at: ~N[2020-07-08 11:00:00],
                 author: nil,
                 image: nil,
                 url: "https://www.oslobodjenje.ba/naslovnica/na-danasnji-dan-8-juli-569244"
               },
               %{
                 original_id: "570770",
                 title:
                   "Rasizam u Rusiji: Priče o predrasudama u zemlji gde protesti Crni životi nemaju uticaj",
                 description: nil,
                 published_at: ~N[2020-07-06 05:14:02],
                 author: nil,
                 image: nil,
                 url:
                   "https://www.oslobodjenje.ba/vijesti/bbc-news/rasizam-u-rusiji-price-o-predrasudama-u-zemlji-gde-protesti-crni-zivoti-nemaju-uticaj-570770"
               }
             ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/naslovnica/na-danasnji-dan-8-juli-569244",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url = "http://localhost:#{bypass.port}/naslovnica/na-danasnji-dan-8-juli-569244"

      article = %{
        original_id: "569244",
        title: "Na današnji dan - 8. juli",
        description: nil,
        published_at: ~N[2020-07-08 11:00:00],
        author: nil,
        image: nil,
        url: article_url
      }

      response = OslobodjenjeScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "569244",
               title: "Na današnji dan - 8. juli",
               description: nil,
               published_at: ~N[2020-07-08 11:00:00],
               author: nil,
               image: "https://cdn.oslobodjenje.ba/images/slike/api/2020/07/01/3754521.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/oslobodjenje_scraper/feed.xml")
  end

  defp article_payload do
    File.read!("test/support/payloads/oslobodjenje_scraper/article.html")
  end
end
