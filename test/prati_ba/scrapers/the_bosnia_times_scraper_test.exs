defmodule PratiBa.Scrapers.TheBosniaTimesScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.TheBosniaTimesScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/posts/", fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = TheBosniaTimesScraper.articles("http://localhost:#{bypass.port}")

      first_image_url = "http://localhost:#{bypass.port}/wp-json/wp/v2/media/47803"
      second_image_url = "http://localhost:#{bypass.port}/wp-json/wp/v2/media/47800"

      assert {:ok, articles} = response
      articles = Enum.to_list(articles)

      assert length(articles) == 10

      assert [
               %{
                 original_id: "47802",
                 title:
                   "EVO KAKAV UHLJEB VODI SABOR ISLAMSKE ZAJEDNICE: Zbog njegovog kašnjenja na sjednice ne usvajaju se zakoni, a on prima plaću od 7000 KM",
                 description:
                   "Danas je u 10.30 održana sjednica Ustavno pravne komisije Zastupničkog doma PS BiH. Prisutni su bili: 2 HDZ, 2 SNSD, 1 SDS, 1 SDA, 1 SDP, 1 DF. Odsutan Safet Softić iz SDA. Svi zakoni koji su razmatrani imali su negativan izvještaj UPK, jer su HDZ-ovi i SNSD-ovi zastupnici bili protiv, naspram 4 zastupnika koja […]",
                 published_at: ~N[2020-07-06 22:27:57],
                 author: nil,
                 image: ^first_image_url,
                 url:
                   "https://thebosniatimes.ba/47802/evo-kakav-uhljeb-vodi-sabor-islamske-zajednice-zbog-njegovog-kasnjenja-na-sjednice-ne-usvajaju-se-zakoni-a-on-prima-placu-od-7000-km/"
               },
               %{
                 original_id: "47799",
                 title: "KO JE NOVI LIDER SDP-a: Nije Mujo, ali jeste Mostarac i Komadina",
                 description:
                   "Ko je novi šef SDP-a Zlatko Komadina? Zna se da se radi o iskusnom političaru, s puno utakmica u nogama i jednim od najuspješnijih funkcionera u toj stranci. Na njemu je da konsolidira SDP do izbora za novog predsjednika, nakon totalnog debakla na izborima. Međutim, zanimljivo je da, iako živi u Rijeci i preteča je […]",
                 published_at: ~N[2020-07-06 20:18:20],
                 author: nil,
                 image: ^second_image_url,
                 url:
                   "https://thebosniatimes.ba/47799/ko-je-novi-lider-sdp-a-nije-mujo-ali-jeste-mostarac-i-komadina/"
               }
             ] = Enum.take(articles, 2)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/wp-json/wp/v2/media/47803", fn conn ->
        Plug.Conn.resp(conn, 200, media_payload())
      end)

      article = %{
        original_id: "47802",
        title:
          "EVO KAKAV UHLJEB VODI SABOR ISLAMSKE ZAJEDNICE: Zbog njegovog kašnjenja na sjednice ne usvajaju se zakoni, a on prima plaću od 7000 KM",
        description:
          "Danas je u 10.30 održana sjednica Ustavno pravne komisije Zastupničkog doma PS BiH. Prisutni su bili: 2 HDZ, 2 SNSD, 1 SDS, 1 SDA, 1 SDP, 1 DF. Odsutan Safet Softić iz SDA. Svi zakoni koji su razmatrani imali su negativan izvještaj UPK, jer su HDZ-ovi i SNSD-ovi zastupnici bili protiv, naspram 4 zastupnika koja […]",
        published_at: ~N[2020-07-06 22:27:57],
        author: nil,
        image: "http://localhost:#{bypass.port}/wp-json/wp/v2/media/47803",
        url:
          "https://thebosniatimes.ba/47802/evo-kakav-uhljeb-vodi-sabor-islamske-zajednice-zbog-njegovog-kasnjenja-na-sjednice-ne-usvajaju-se-zakoni-a-on-prima-placu-od-7000-km/"
      }

      response = TheBosniaTimesScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "47802",
               title:
                 "EVO KAKAV UHLJEB VODI SABOR ISLAMSKE ZAJEDNICE: Zbog njegovog kašnjenja na sjednice ne usvajaju se zakoni, a on prima plaću od 7000 KM",
               description:
                 "Danas je u 10.30 održana sjednica Ustavno pravne komisije Zastupničkog doma PS BiH. Prisutni su bili: 2 HDZ, 2 SNSD, 1 SDS, 1 SDA, 1 SDP, 1 DF. Odsutan Safet Softić iz SDA. Svi zakoni koji su razmatrani imali su negativan izvještaj UPK, jer su HDZ-ovi i SNSD-ovi zastupnici bili protiv, naspram 4 zastupnika koja […]",
               published_at: ~N[2020-07-06 22:27:57],
               author: nil,
               image: "https://thebosniatimes.ba/wp-content/uploads/2020/07/SOFTIC-SLIKA-1-1.png",
               url:
                 "https://thebosniatimes.ba/47802/evo-kakav-uhljeb-vodi-sabor-islamske-zajednice-zbog-njegovog-kasnjenja-na-sjednice-ne-usvajaju-se-zakoni-a-on-prima-placu-od-7000-km/"
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/the_bosnia_times_scraper/posts.json")
  end

  defp media_payload do
    File.read!("test/support/payloads/the_bosnia_times_scraper/media.json")
  end
end
