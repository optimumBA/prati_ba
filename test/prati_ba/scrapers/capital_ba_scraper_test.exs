defmodule PratiBa.Scrapers.CapitalBaScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.CapitalBaScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = CapitalBaScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 30

      assert %{
        original_id: nil,
        title: "Pregovori propali, radnici Lufthanze ulaze u štrajk",
        description: nil,
        published_at: nil,
        author: nil,
        image: nil,
        url: "https://www.capital.ba/pregovori-propali-radnici-lufthanze-ulaze-u-strajk/"
      } = Enum.at(articles, 0)


    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/pregovori-propali-radnici-lufthanze-ulaze-u-strajk/",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/pregovori-propali-radnici-lufthanze-ulaze-u-strajk/"

      article = %{
        original_id: nil,
        title:
          "Pregovori propali, radnici Lufthanze ulaze u štrajk",
        description: nil,
        published_at: nil,
        author: nil,
        image_url: nil,
        url: article_url
      }

      response = CapitalBaScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: nil,
               title:
                 "Pregovori propali, radnici Lufthanze ulaze u štrajk",
               description: "Njemački državni prevoznik suočava se s novim prekidima u radu jer su posljednji pregovori između sindikata i uprave propali. Predstavnici radnika najavili su štrajk za petak.",
               published_at: ~N[2022-09-01 11:30:00],
               author: nil,
               image_url: "https://www.capital.ba/wp-content/uploads/2021/06/aircraft-1362586_1280-e1659951124385.jpg",
               url: ^article_url
             } = article
    end
  end


  defp articles_payload do
    File.read!("test/support/payloads/capital_ba_scraper/articles.html")
  end
  defp article_payload do
    File.read!("test/support/payloads/capital_ba_scraper/article.html")
  end
end
