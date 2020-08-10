defmodule PratiBa.Scrapers.BljesakScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.BljesakScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = BljesakScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      articles = Enum.to_list(articles)

      assert length(articles) == 20

      assert %{
               original_id: "317067",
               title: "Procurile nove informacije o nadolazećem Samsungovom savitljivom telefonu",
               description: nil,
               published_at: nil,
               author: nil,
               image: nil,
               url:
                 "https://www.bljesak.info/sci-tech/tehnologija/procurile-nove-informacije-o-nadolazecem-samsungovom-savitljivom-telefonu/317067"
             } = Enum.at(articles, 0)
    end
  end

  describe "article_details/1" do
    test "fetches more article info", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/sci-tech/internet/poruka-koju-ste-dobili-na-whatsapp-izgleda-sumnjivo-provjerite-njenu-tocnost-na-internetu/319902",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/sci-tech/internet/poruka-koju-ste-dobili-na-whatsapp-izgleda-sumnjivo-provjerite-njenu-tocnost-na-internetu/319902"

      article = %{
        original_id: "319902",
        title: "Poruka koju ste dobili na WhatsApp izgleda sumnjivo? Provjerite njenu točnost na internetu",
        description: nil,
        published_at: nil,
        author: nil,
        image: nil,
        url: article_url
      }

      response = BljesakScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "319902",
               title: "Poruka koju ste dobili na WhatsApp izgleda sumnjivo? Provjerite njenu točnost na internetu",
               description:
                 "WhatsApp predstavio je još jednu opciju kojom žele, ako ne spriječiti, onda barem smanjiti širenje lažnih informacija.",
               published_at: ~N[2020-08-04 16:39:00],
               author: nil,
               image: "https://storage.bljesak.info/article/319902/800x550/WhatsApp.jpg",
               url: ^article_url
             } = article
    end

    test "works with different article format", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/kultura/vjera/nepravda-tesko-zlo-i-zlocin-jos-uvijek-strasno-zaudaraju-necovjestvom/318379",
        fn conn ->
          Plug.Conn.resp(conn, 200, different_article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/kultura/vjera/nepravda-tesko-zlo-i-zlocin-jos-uvijek-strasno-zaudaraju-necovjestvom/318379"

      article = %{
        original_id: "318379",
        title: "Ubija se istina da se ubilo čovjeka",
        description: nil,
        published_at: nil,
        author: nil,
        image: nil,
        url: article_url
      }

      response = BljesakScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "318379",
               title: "Ubija se istina da se ubilo čovjeka",
               description:
                 "Franjo Komarica, biskup banjalučki, povodom današnjeg ukopa šest prijedorskih žrtava u Memorijalnom centru Kamičani",
               published_at: ~N[2020-07-20 09:30:00],
               author: nil,
               image: "https://storage.bljesak.info/article/318379/800x550/franjo-komarica.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/bljesak_scraper/articles.html")
  end

  defp article_payload do
    File.read!("test/support/payloads/bljesak_scraper/article.html")
  end

  defp different_article_payload do
    File.read!("test/support/payloads/bljesak_scraper/different_article.html")
  end
end
