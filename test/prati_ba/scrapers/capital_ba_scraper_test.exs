defmodule PratiBa.Scrapers.CapitalBaScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.CapitalBaScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/posts/", fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = CapitalBaScraper.articles("http://localhost:#{bypass.port}")

      first_image_url = "http://localhost:#{bypass.port}/wp-json/wp/v2/media/511665"

      {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 10

      assert [
               %{
                 original_id: "721397",
                 title: "Smanjenjem akciza gorivo jeftinije 50 feninga šest mjeseci",
                 description:
                   "Ranije su Predstavnički dom i Dom naroda usvojili ukidanje akciza na gorivo u različitim verzijama.",
                 published_at: ~N[2022-09-12 14:45:53],
                 author: nil,
                 image: ^first_image_url,
                 url:
                   "https://www.capital.ba/smanjenjem-akciza-gorivo-jeftinije-50-feninga-sest-mjeseci/"
               }
             ] = Enum.take(articles, 1)
    end
  end

  describe "article_details/1" do
    test "fetches articles image", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/media/721373", fn conn ->
        Plug.Conn.resp(conn, 200, media_payload())
      end)

      article = %{
        original_id: "721373",
        title: nil,
        description: nil,
        published_at: ~N[2022-09-12T14:45:53],
        author: nil,
        image: "http://localhost:#{bypass.port}/wp-json/wp/v2/media/721373",
        url: "https://www.capital.ba/smanjenjem-akciza-gorivo-jeftinije-50-feninga-sest-mjeseci/"
      }

      response = CapitalBaScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "721373",
               title: nil,
               description: nil,
               published_at: ~N[2022-09-12 14:45:53],
               author: nil,
               image:
                 "https://www.capital.ba/wp-content/uploads/2022/09/zlato-poluge-foto-pixabay.jpg",
               url:
                 "https://www.capital.ba/smanjenjem-akciza-gorivo-jeftinije-50-feninga-sest-mjeseci/"
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/capital_ba_scraper/posts.json")
  end

  defp media_payload do
    File.read!("test/support/payloads/capital_ba_scraper/media.json")
  end
end
