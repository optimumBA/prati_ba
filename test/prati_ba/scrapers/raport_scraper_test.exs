defmodule PratiBa.Scrapers.RaportScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.RaportScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect bypass, "GET", "/wp-json/wp/v2/posts/", fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end

      Bypass.expect bypass, "GET", "/wp-json/wp/v2/media/29016", fn conn ->
        Plug.Conn.resp(conn, 200, media_payload(29016))
      end

      Bypass.expect bypass, "GET", "/wp-json/wp/v2/media/29013", fn conn ->
        Plug.Conn.resp(conn, 200, media_payload(29013))
      end

      response = RaportScraper.articles("http://localhost:#{bypass.port}")

      assert {:ok, articles} = response
      assert [
        %{
          original_id: "29015",
          title: "Uskoro formiranje tima za restrukturiranje preduzeća GRAS",
          description: "Premijer Kantona Sarajevo Mario Nenadić, ministar saobraćaja Adi Kalem i ministar finansija Jasmin Halebić razgovarali su s v.d. direktorom GRAS-a Almirom Ahmetspahićem, rukovodiocem Sektora za razvoj Mustafom Mehanovićem, i predstavnicima sindikata GRAS-a Amirom Muminovićem i Adnanom Himzanijom o restruktuiranju tog preduzeća. Sastanak je inicirao Nenadić kako bi bili određeni budući koraci djelovanja radi unapređenja korporativnog […]",
          published_at: ~N[2020-07-03 07:43:01],
          author: nil,
          image: "https://raport.ba/wp-content/uploads/2020/07/gras1.jpg",
          url: "https://raport.ba/uskoro-formiranje-tima-za-restrukturiranje-preduzeca-gras/",
        },
        %{
          original_id: "29012",
          title: "Krenuo Marš mira Sarajevo-Nezuk: Da se nikad nikome ne ponovi Srebrenica",
          description: "Učesnici devetog Marša mira “Sarajevo – Nezuk” u organizaciji Udruženja građana “Svjedoci svog vremena”, uprkos pandemiji koronavirusa, krenuo je na jutros na pohod dug više od 150 kilometara u spomen na nekoliko hiljada Srebreničana koji su jula 1995. godine prepješačili put da bi pronašli spas u Tuzli. Jedan od organizatora Marša Muhamed Papić kazao je […]",
          published_at: ~N[2020-07-03 07:18:49],
          author: nil,
          image: "https://raport.ba/wp-content/uploads/2020/07/mars-mira3.jpg",
          url: "https://raport.ba/krenuo-mars-mira-sarajevo-nezuk-da-se-nikad-nikome-ne-ponovi-srebrenica/",
        },
      ] = Enum.to_list(articles)
    end
  end

  defp articles_payload do
    File.read!("test/support/payloads/raport_scraper/posts.json")
  end

  defp media_payload(id) do
    File.read!("test/support/payloads/raport_scraper/media_#{id}.json")
  end
end
