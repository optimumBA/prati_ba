defmodule PratiBa.Scrapers.PreokretInfoScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.PreokretInfoScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/posts/", fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = PreokretInfoScraper.articles("http://localhost:#{bypass.port}")

      first_image_url = "http://localhost:#{bypass.port}/wp-json/wp/v2/media/46250"

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 10

      assert [
               %{
                 original_id: "46249",
                 title: "LJUBODRAG STOJADINOVIĆ: Specijalni zagrljaj",
                 description:
                   "Velika sportska dostignuća Novaka Đokovića donekle pripadaju prošlosti. On sve ređe odlazi na najvažnije turnire i njegova se karijera bliži prirodnom kraju. Svakako najveći sportista u istoriji ove zemlje davno je postao predmet opšte ljubavi. Kao da je svako od nas uzeo za sebe parče njegove neuporedive slave, pa je Novak Đoković sve naše nemoći …\n  LJUBODRAG STOJADINOVIĆ: Specijalni zagrljaj Read More »",
                 published_at: ~N[2022-09-02 10:59:07],
                 author: nil,
                 image: ^first_image_url,
                 url:
                   "https://preokret.info/index.php/2022/09/02/ljubodrag-stojadinovic-specijalni-zagrljaj/"
               }
             ] = Enum.take(articles, 1)
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/preokret_info_scraper/posts.json")
  end
end
