defmodule PratiBa.Scrapers.RaportScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.RaportScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/posts/", fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = RaportScraper.articles("http://localhost:#{bypass.port}")

      first_image_url = "http://localhost:#{bypass.port}/wp-json/wp/v2/media/291381"

      {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 2

      assert [
               %{
                 author: nil,
                 description:
                   "Na ovogodišnjem, 66. izdanju svečanosti dodjele Zlatne lopte magazina France Football za najboljeg nogometaša svijeta, koja će se održati 17. oktobra u pariškom pozorištu Chatelet, prvi put dodijelit će se i nagrada “Prix Socrates” za društvenu predanost. Nagradu Socrates, nazvanu po legendi brazilskog nogometa, ljekaru, filozofu i predanom građaninu koji […]",
                 image: ^first_image_url,
                 original_id: "291380",
                 published_at: ~N[2022-09-21 11:30:00],
                 title:
                   "Prvi put će se na Zlatnoj lopti i dodijeliti nagrada nazvana po brazilskoj legendi",
                 url:
                   "https://raport.ba/prvi-put-ce-se-na-zlatnoj-lopti-i-dodijeliti-nagrada-nazvana-po-brazilskoj-legendi/"
               }
             ] = Enum.take(articles, 1)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/media/291381", fn conn ->
        Plug.Conn.resp(conn, 200, media_payload())
      end)

      article = %{
        original_id: "291380",
        title:
          "Prvi put će se na Zlatnoj lopti i dodijeliti nagrada nazvana po brazilskoj legendi",
        description:
          "Na ovogodišnjem, 66. izdanju svečanosti dodjele Zlatne lopte magazina France Football za najboljeg nogometaša svijeta, koja će se održati 17. oktobra u pariškom pozorištu Chatelet, prvi put dodijelit će se i nagrada “Prix Socrates” za društvenu predanost. Nagradu Socrates, nazvanu po legendi brazilskog nogometa, ljekaru, filozofu i predanom građaninu koji […]",
        published_at: ~N[2020-07-03 07:18:49],
        author: nil,
        image: "http://localhost:#{bypass.port}/wp-json/wp/v2/media/291381",
        url:
          "https://raport.ba/prvi-put-ce-se-na-zlatnoj-lopti-i-dodijeliti-nagrada-nazvana-po-brazilskoj-legendi/"
      }

      response = RaportScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               author: nil,
               description:
                 "Na ovogodišnjem, 66. izdanju svečanosti dodjele Zlatne lopte magazina France Football za najboljeg nogometaša svijeta, koja će se održati 17. oktobra u pariškom pozorištu Chatelet, prvi put dodijelit će se i nagrada “Prix Socrates” za društvenu predanost. Nagradu Socrates, nazvanu po legendi brazilskog nogometa, ljekaru, filozofu i predanom građaninu koji […]",
               image: "https://raport.ba/wp-content/uploads/2022/09/sokrates-4.png",
               original_id: "291380",
               published_at: ~N[2020-07-03 07:18:49],
               title:
                 "Prvi put će se na Zlatnoj lopti i dodijeliti nagrada nazvana po brazilskoj legendi",
               url:
                 "https://raport.ba/prvi-put-ce-se-na-zlatnoj-lopti-i-dodijeliti-nagrada-nazvana-po-brazilskoj-legendi/"
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/raport_scraper/posts.json")
  end

  defp media_payload do
    File.read!("test/support/payloads/raport_scraper/media.json")
  end
end
