defmodule PratiBa.Scrapers.SourceScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.SourceScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = SourceScraper.articles("http://localhost:#{bypass.port}")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 5

      assert %{
               original_id: "526963",
               title: "Beogradski protesti: I večeras napadnut novinar",
               description: nil,
               published_at: nil,
               author: nil,
               image: nil,
               url:
                 "http://www.source.ba/clanak/Region/526963/Beogradski-protesti--I-veceras-napadnut-novinar"
             } = Enum.at(articles, 0)
    end
  end

  describe "article_details/1" do
    test "fetches article details", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/clanak/BiH/526970/Premijer-Novalic-pridruzio-se-Marsu-mira--Obaveza-mi-je-kao-covjeku-proci-bar-dijelom-rute",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/clanak/BiH/526970/Premijer-Novalic-pridruzio-se-Marsu-mira--Obaveza-mi-je-kao-covjeku-proci-bar-dijelom-rute"

      article = %{
        original_id: "526970",
        title:
          "Premijer Novalić pridružio se Maršu mira: Obaveza mi je kao čovjeku proći bar dijelom rute",
        description: nil,
        published_at: nil,
        author: nil,
        image: nil,
        url: article_url
      }

      response = SourceScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "526970",
               title:
                 "Premijer Novalić pridružio se Maršu mira: Obaveza mi je kao čovjeku proći bar dijelom rute",
               description:
                 "Premijer Federacije Bosne i Hercegovine Fadil Novalić i federalni ministar za pitanja boraca i invalida odbrambeno-oslobodilačkog rata Salko Bukvarević pridružili su se rano jutros učesnicima Marša mira na početku treće, ujedno i posljednje, dionice u Mravinjcima.",
               published_at: ~N[2020-07-10 06:42:00],
               author: "Patria",
               image:
                 "http://www.source.ba/local_files/pocetneSlike/a72c07b2c40b4157a6ddc2221d79e931.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/source_scraper/articles.html")
  end

  defp article_payload do
    File.read!("test/support/payloads/source_scraper/article.html")
  end
end
