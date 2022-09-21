defmodule PratiBa.Scrapers.N1ScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.N1Scraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/posts/", fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      first_image_url = "http://localhost:#{bypass.port}/wp-json/wp/v2/media/5104499"

      response = N1Scraper.articles("http://localhost:#{bypass.port}")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 2

      assert [
               %{
                 original_id: "5311603",
                 title:
                   "Nikšić odgovorio na špekulacije: Nismo na prodaju i nećemo spašavati SDA!",
                 description: nil,
                 published_at: ~N[2022-09-14 16:55:58],
                 author: nil,
                 image: ^first_image_url,
                 url:
                   "https://ba.n1info.com/vijesti/niksic-odgovorio-na-spekulacije-nismo-na-prodaju-i-necemo-spasavati-sda/"
               }
             ] = Enum.take(articles, 1)
    end
  end

  describe "article_details/1" do
    test "fetches articles image", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/media/5312342", fn conn ->
        Plug.Conn.resp(conn, 200, media_payload())
      end)

      article = %{
        original_id: "5312342",
        title: nil,
        description: nil,
        published_at: ~N[2022-09-11T15:07:57],
        author: nil,
        image: "http://localhost:#{bypass.port}/wp-json/wp/v2/media/5312342",
        url:
          "https://ba.n1info.com/sport-klub/kosarka/selektor-poljske-moji-igraci-imaju-jja-kao-lubenice-srce-kao-mjesec/attachment/eurobasket-championship-quarter-final-slovenia-v-poland-4/"
      }

      response = N1Scraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "5312342",
               title: nil,
               description: nil,
               published_at: ~N[2022-09-11 15:07:57],
               author: nil,
               image:
                 "https://ba.n1info.com/wp-content/uploads/2022/09/14/1663189961-2022-09-14T204242Z_419730309_UP1EI9E1LJ3M6_RTRMADP_3_BASKETBALL-EUROBASKET-SVN-POL-scaled.jpg",
               url:
                 "https://ba.n1info.com/sport-klub/kosarka/selektor-poljske-moji-igraci-imaju-jja-kao-lubenice-srce-kao-mjesec/attachment/eurobasket-championship-quarter-final-slovenia-v-poland-4/"
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/n1_scraper/posts.json")
  end

  defp media_payload do
    File.read!("test/support/payloads/n1_scraper/media.json")
  end
end
