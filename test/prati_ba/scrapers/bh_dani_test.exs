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

      assert assert [
                      %{
                        original_id: "788005",
                        title:
                          "Švicarske tajne domaćeg carinika: Jesu li bh. vlasti zaboravile Janka Jovanovića?",
                        description: nil,
                        published_at: ~N[2022-09-12 11:30:00],
                        author: nil,
                        image:
                          "https://cdn.oslobodjenje.ba/images/slike/new/2022/08/29/6343952.jpg",
                        url:
                          "https://bhdani.oslobodjenje.ba/bhdani/svicarske-tajne-domaceg-carinika-jesu-li-bh-vlasti-zaboravile-janka-jovanovica-788005"
                      }
                    ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/svicarske-tajne-domaceg-carinika-jesu-li-bh-vlasti-zaboravile-janka-jovanovica-788005",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/svicarske-tajne-domaceg-carinika-jesu-li-bh-vlasti-zaboravile-janka-jovanovica-788005"

      article = %{
        original_id: "788005",
        title:
          "Švicarske tajne domaćeg carinika: Jesu li bh. vlasti zaboravile Janka Jovanovića?",
        description: nil,
        published_at: ~N[2022-09-12 11:30:00],
        author: nil,
        image: nil,
        url: article_url
      }

      response = BhDaniScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "788005",
               title:
                 "Švicarske tajne domaćeg carinika: Jesu li bh. vlasti zaboravile Janka Jovanovića?",
               description: nil,
               published_at: ~N[2022-09-12 11:30:00],
               author: nil,
               image: "https://cdn.oslobodjenje.ba/images/slike/new/2022/08/29/6343952.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/bh_dani_scraper/feed.xml")
  end

  defp article_payload do
    File.read!("test/support/payloads/bh_dani_scraper/article.html")
  end
end
