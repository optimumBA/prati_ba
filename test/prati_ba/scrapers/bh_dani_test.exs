defmodule PratiBa.Scrapers.BhDaniTest do
  use ExUnit.Case, async: true
  alias PratiBa.Scrapers.BhDaniScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = BhDaniScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 1

      assert %{
               original_id: "778048",
               title: "Na kontinentu koji se nekad zvao Evropa: Mutantova priča",
               description: nil,
               published_at: nil,
               author: nil,
               image: nil,
               url:
                 "https://bhdani.oslobodjenje.ba//bhdani/na-kontinentu-koji-se-nekad-zvao-evropa-mutantova-prica-778048"
             } = Enum.at(articles, 0)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/na-kontinentu-koji-se-nekad-zvao-evropa-mutantova-prica-778048",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/na-kontinentu-koji-se-nekad-zvao-evropa-mutantova-prica-778048"

      article = %{
        original_id: "778048",
        title: "Na kontinentu koji se nekad zvao Evropa: Mutantova priča",
        description: nil,
        published_at: ~N[2022-08-30 07:17:00],
        author: nil,
        image: nil,
        url: article_url
      }

      response = BhDaniScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "778048",
               title: "Na kontinentu koji se nekad zvao Evropa: Mutantova priča",
               description: nil,
               published_at: ~N[2022-08-30 07:17:00],
               author: nil,
               image: "https://cdn.oslobodjenje.ba/images/slike/new/2022/07/22/6276563.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/bh_dani_scraper/articles.html")
  end

  defp article_payload do
    File.read!("test/support/payloads/bh_dani_scraper/article.html")
  end
end
