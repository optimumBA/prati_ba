defmodule PratiBa.Scrapers.PrvaSmjenaScraperTest do
  use ExUnit.Case, async: true

  alias PratiBa.Scrapers.PrvaSmjenaScraper

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "articles/1" do
    test "fetches articles", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, articles_payload())
      end)

      response = PrvaSmjenaScraper.articles("http://localhost:#{bypass.port}/")

      assert {:ok, articles} = response

      assert [
               %{
                 author: nil,
                 description:
                   "Oporavak svjetskoga gospodarstva trenutačno je neuravnotežen, a pandemija je istodobno utjecala kako na proizvodnju tako i na transport hrane. To je rezultiralo naglim rastom broja gladnih. Prema izvješću ‘’Globalna sigurnost...",
                 image: nil,
                 original_id: "2328",
                 published_at: ~N[2022-07-20 07:39:31],
                 title: "Kina je pozitivna snaga u održavanju svjetske sigurnosti hrane",
                 url:
                   "https://prvasmjena.com/kina-je-pozitivna-snaga-u-odrzavanju-svjetske-sigurnosti-hrane/"
               },
               %{
                 author: nil,
                 description:
                   "Naoružani napadač ubio je troje ljudi u nedjelju u restoranu trgovačkog centra u blizini Indianapolisa, prije nego što ga je ustrijelio i ubio naoružani slučajni prolaznik, izvijestio je šef policije...",
                 image: nil,
                 original_id: "2324",
                 published_at: ~N[2022-07-18 07:13:37],
                 title:
                   "Opet u Americi: Napadač ubio troje ljudi u trgovačkom centru – napadača ubio naoružani prolaznik",
                 url:
                   "https://prvasmjena.com/opet-u-americi-napadac-ubio-troje-ljudi-u-soping-centru-napadaca-ubio-naoruzani-prolaznik/"
               }
             ] = Enum.to_list(articles)
    end
  end

  describe "article_details/1" do
    test "fetches article image", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/milorad-dodik-brani-fadila-novalica-niko-ne-bi-trebao-odgovarati-za-nabavku-u-ekstremno-teskim-uvjetima/",
        fn conn ->
          Plug.Conn.resp(conn, 200, article_payload())
        end
      )

      article_url =
        "http://localhost:#{bypass.port}/milorad-dodik-brani-fadila-novalica-niko-ne-bi-trebao-odgovarati-za-nabavku-u-ekstremno-teskim-uvjetima/"

      article = %{
        original_id: "1773",
        title:
          "Milorad Dodik brani Fadila Novalića: Niko ne bi trebao odgovarati za nabavku u ekstremno teškim uvjetima",
        description:
          "Komentirajući odgovor Bosne i Hercegovine na pandemiju korona virusa, Milorad Dodik je kazao za N1 kako BiH čini sve što i druge zemlje te naglasio kako taj period ne bi...",
        published_at: ~N[2020-07-02 16:37:03],
        author: nil,
        image: nil,
        url: article_url
      }

      response = PrvaSmjenaScraper.article_details(article)

      assert {:ok, article} = response

      assert %{
               original_id: "1773",
               title:
                 "Milorad Dodik brani Fadila Novalića: Niko ne bi trebao odgovarati za nabavku u ekstremno teškim uvjetima",
               description:
                 "Komentirajući odgovor Bosne i Hercegovine na pandemiju korona virusa, Milorad Dodik je kazao za N1 kako BiH čini sve što i druge zemlje te naglasio kako taj period ne bi...",
               published_at: ~N[2020-07-02 16:37:03],
               author: nil,
               image: "http://prvasmjena.com/wp-content/uploads/2020/07/bake-dodo.jpg",
               url: ^article_url
             } = article
    end
  end

  defp articles_payload do
    ~s"""
    <?xml version="1.0" encoding="UTF-8"?><rss version="2.0"
    xmlns:content="http://purl.org/rss/1.0/modules/content/"
    xmlns:wfw="http://wellformedweb.org/CommentAPI/"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
    xmlns:slash="http://purl.org/rss/1.0/modules/slash/"
    >

    <channel>
    <title>Prva Smjena</title>
    <atom:link href="https://prvasmjena.com/feed/" rel="self" type="application/rss+xml" />
    <link>https://prvasmjena.com</link>
    <description>Portal za kritički proboj</description>
    <lastBuildDate>Wed, 20 Jul 2022 07:41:19 +0000</lastBuildDate>
    <language>en-US</language>
    <sy:updatePeriod>
    hourly	</sy:updatePeriod>
    <sy:updateFrequency>
    1	</sy:updateFrequency>
    <generator>https://wordpress.org/?v=5.9.4</generator>

    <image>
    <url>https://prvasmjena.com/wp-content/uploads/2021/11/cropped-logo-jedan-1-32x32.png</url>
    <title>Prva Smjena</title>
    <link>https://prvasmjena.com</link>
    <width>32</width>
    <height>32</height>
    </image>
    <item>
      <title>Kina je pozitivna snaga u održavanju svjetske sigurnosti hrane</title>
      <link>https://prvasmjena.com/kina-je-pozitivna-snaga-u-odrzavanju-svjetske-sigurnosti-hrane/</link>

      <dc:creator><![CDATA[Redakcija]]></dc:creator>
      <pubDate>Wed, 20 Jul 2022 07:39:31 +0000</pubDate>
          <category><![CDATA[Osvrti]]></category>
      <guid isPermaLink="false">https://prvasmjena.com/?p=2328</guid>

            <description><![CDATA[Oporavak svjetskoga gospodarstva trenutačno je neuravnotežen, a pandemija je istodobno utjecala kako na proizvodnju tako i na transport hrane. To je rezultiralo naglim rastom broja gladnih. Prema izvješću ‘’Globalna sigurnost...]]></description>
                      <content:encoded><![CDATA[<p>Oporavak svjetskoga gospodarstva trenutačno je neuravnotežen, a pandemija je istodobno utjecala kako na proizvodnju tako i na transport hrane. To je rezultiralo naglim rastom broja gladnih. Prema izvješću ‘’Globalna sigurnost hrane i stanje ishrane’’, koje je Organizacija Ujedinjenih nacija za hranu i poljoprivredu (FAO) objavila prošle godine, jedna trećine svjetske populacije nije imala dovoljno hrane u 2020. godini. To je za 320 milijuna ljudi više nego godinu prije. Ukupan broj gladnih u svijetu sada je već dostigao oko 800 milijuna. U tako ozbiljnoj situaciji svijet neće moći postići cilj “Nula gladi” do 2030. godine te se Agenda održivog razvoja suočava s velikim izazovima koji zahtijevaju žurne i hrabre akcije, posebno na rješavanju nejednakosti u pristupu hrani. Stara kineska fraza kaže “Hrana je ljudima važna kao nebo.” Kina oduvijek daje veliki značaj hrani i poljoprivrednoj proizvodnji te, kao i uvijek, rješavanje pitanja vezanih za hranu smatra prioritetom u upravljanju državom. Nakon osnivanja Narodne Republike Kine, iskoristivši 9% obradive zemlje u svijetu, riješili smo pitanje opskrbljivanja hranom za više od 1,4 milijarde ljudi i postigli povijesnu promjenu od “nedovoljno jesti”, preko “dovoljno jesti” do “dobro jesti”.</p>
    <p>U 2021. godini, ukupna proizvodnja žitarica u Kini iznosila je 682,8 milijardi kilograma. Taj iznos je sedam godina zaredom iznad 650 milijardi kilograma. Agnes Kalibata, posebna izaslanica glavnog tajnika UN-a za summit o prehrambenim sustavima, rekla je da je Kina dobro upravljala zalihama žitarica, što ne samo da osigurava svoju opskrbu hrane nego i doprinosi sigurnosti hrane svijeta. Kina je pouzdan partner Ujedinjenih naroda i zemalja u razvoju u oblasti sigurnosti hrane. Podržavamo Svjetski program za hranu u uspostavi globalnog humanitarnog skladišta i čvorišta za hitne slučajeve u Kini. S Organizacijom UN-a za hranu i poljoprivredu formirali smo povjerenički fond za jug-jug suradnju i pružili financijsku podršku. U okviru ovoga fonda, surađujući s Organizacijom UN-a za hranu i poljoprivredu i Svjetskim programom za hranu, proveli smo više od 40 projekata. Nadalje, Kina je uspostavila zone poljoprivredne suradnje u zemljama u razvoju, izvršila razmjenu znanstvenog i tehnološkog znanja s više od 140 zemalja i regija te promovirala više od 1000 poljoprivrednih tehnologija u zemljama u razvoju. To je dovelo do povećanja prosječnog prinosa usjeva u projektnim područjima za 30 &#8211; 60%. Godine 1979. Kina je prvi put drugoj zemlji ponudila sjeme hibridne riže. Više od 40 godina je prošlo, kineska hibridna riža popularizirana je u desetinama zemalja i regija u Aziji, Africi i Americi, s godišnjom površinom sadnje od osam milijuna hektara. Tijekom proteklih 40 godina kineski istraživači došli su u Indiju, Pakistan, Vijetnam, Mjanmar i Bangladeš na savjetovanje i konzultacije te su preko međunarodnih tečajeva obučili više od 14.000 stručnjaka za hibridnu rižu za više od 80 zemalja u razvoju.</p>
    <p>U travnju 2017. godine, Qu Dongyu, sadašnji glavni direktor Organizacije UN-a za hranu i poljoprivredu i tadašnji zamjenik ministra poljoprivrede Kine posjetio je Bosnu i Hercegovinu i sastao se s tadašnjim članom Predsjedništva BiH Draganom Čovićem te drugim dužnosnicima BiH, čime je otvoreno novo poglavlje suradnje prerade poljoprivrednih proizvoda i poljoprivredne opreme među dvjema zemljama. Polazeći od pretpostavke osiguravanja državne sigurnosti hrane, Kina dijeli ogromno kinesko tržište žitarica s najvećim svjetskim proizvođačima žitarica. U proteklih 20 godina, od pristupanja Svjetskoj trgovinskoj organizaciji, Kina je ukinula necarinske mjere kao što su uvozne kvote i dozvole za odgovarajuće poljoprivredne proizvode i uvelike smanjila uvozne carine na druge žitarice. Od početka ove godine Kina je zemljama u razvoju pružila hitnu humanitarnu pomoću u količini većoj od 15.000 tona žitarica. Kina će nastaviti ulagati nove napore u čuvanje sigurnosti hrane. Ako ima hrane, bit će i stabilnosti, ako nema hrane, bit će kaos. Hrana i energija ključni su čimbenici za zdrav razvoj svjetske ekonomije i učinkovitu realizaciju Agende za održivi razvoj 2030. U rujnu prošle godine, kineski predsjednik Xi Jinping na Generalnoj skupštini UN-a ponudio je inicijativu o globalnom razvoju, fokusirajući se na najžurnija pitanja s kojima se suočavaju zemlje u razvoju. Predjednik Xi istaknuo je sigurnost hrane kao ključno područje suradnje u provedbi inicijative globalnog razvoja te pokazao iskrenost Kine da s drugim zemljama radi na rješavanju problema globalne gladi.</p>
    <p>Kina je pozitivna snaga u održavanju svjetske sigurnosti hrane. U lipnju ove godine naš predsjednik je još jednom na ceremoniji otvaranja poslovnog foruma BRICS-a predložio da treba ojačati suradnju u oblasti hrane i energije te poboljšati razinu sigurnosti hrane i energije. Nedavno, na sastanku ministara vanjskih poslova G20 na Baliju, državni savjetnik i ministar vanjskih poslova Wang Yi iznio je stav Kine o pitanju sigurnosti hrane i energije te uime Kine iznio inicijativu za međunarodnu suradnju o sigurnosti hrane i uspostavljanju robnog partnerstva. Prvo, podržavamo UN da igra koordinirajuću ulogu. Treba ojačati, a ne oslabiti ulogu Ujedinjenih naroda. Podržavamo radove FAO-a, Međunarodnog fonda za poljoprivredni razvoj (IFAD) i Svjetskog programa za hranu. Drugo, treba ukinuti ograničenja izvoza na nabavu humanitarne hrane koju provodi Svjetski program za hranu (WFP). Treće, treba omogućiti nesmetan ulazak poljoprivrednih proizvoda i prehrambenih dodataka iz Rusije, Ukrajine i Bjelorusije na međunarodno tržište. Četvrto, glavne zemlje proizvođači žitarica i neto izvoznici trebaju osloboditi svoj izvozni potencijal, smanjiti trgovinske i tehničke barijere, kontrolirati korištenje žitarica za energiju te ublažiti napetost u opskrbljivanju tržišta. Peto, žurne mjere za trgovinu hrane koje uzimaju razne zemlje trebaju biti kratkoročne, transparentne, ciljane i prikladne te u skladu s pravilima STO-a. Šesto, podržavamo Konzultativnu grupu za međunarodna poljoprivredna istraživanja (CGIAR) i suradnju raznih zemalja u oblasti poljoprivrednih znanstvenih i tehnoloških inovacija te smanjenje ograničenja na razmjenu visoke tehnologije. Sedmo, potrebno je smanjiti gubitak hrane. Konačno, osmo, treba pomoći zemljama u razvoju da poboljšaju svoju proizvodnju, skladištenje i sposobnost smanjenja štete u smislu kapitala, tehnologije i tržišta. Kineska sigurnost hrane neodvojiva je od svijeta, a svjetska sigurnost hrane također treba Kinu. Aktivno sudjelujemo u upravljanju svjetskom sigurnošću hrane. Bosna i Hercegovina članica je Mehanizma za poljoprivrednu suradnju Kine i zemalja središnje i istočne Europe (CEEC).</p>
    <p>Solidarno ćemo i dalje surađivati s BiH i drugim zemljama na provedbi UN-ove Agende za održivi razvoj 2030. i na osiguravanju sigurnosti hrane, kako glad ne bi prijetila što većem broju ljudi, a sve više zemalja i regija povećavalo bi kapacitete održive poljoprivredne proizvodnje te realiziralo zajednički prosperitet.</p>
    <p>Ping Ji, ambasador Narodne Republike Kine u BiH</p>
    ]]></content:encoded>



        </item>
      <item>
      <title>Opet u Americi: Napadač ubio troje ljudi u trgovačkom centru &#8211; napadača ubio naoružani prolaznik</title>
      <link>https://prvasmjena.com/opet-u-americi-napadac-ubio-troje-ljudi-u-soping-centru-napadaca-ubio-naoruzani-prolaznik/</link>

      <dc:creator><![CDATA[Redakcija]]></dc:creator>
      <pubDate>Mon, 18 Jul 2022 07:13:37 +0000</pubDate>
          <category><![CDATA[Vijesti]]></category>
      <guid isPermaLink="false">https://prvasmjena.com/?p=2324</guid>

            <description><![CDATA[Naoružani napadač ubio je troje ljudi u nedjelju u restoranu trgovačkog centra u blizini Indianapolisa, prije nego što ga je ustrijelio i ubio naoružani slučajni prolaznik, izvijestio je šef policije...]]></description>
                      <content:encoded><![CDATA[<p>Naoružani napadač ubio je troje ljudi u nedjelju u restoranu trgovačkog centra u blizini Indianapolisa, prije nego što ga je ustrijelio i ubio naoružani slučajni prolaznik, izvijestio je šef policije Greenwooda Jim Ison.</p>
    <p>“Pravi heroj dana je građanin koji je zakonito nosio vatreno oružje u tom restoranu i uspio je zaustaviti napadača praktički čim je počeo pucati”, rekao je novinarima Ison.</p>
    <p>Za naoružanog prolaznika rekao je da je 22-godišnjak.</p>
    <p>Još dvije osobe povrijeđene su u incidentu koji se dogodio u ranim večernjim satima u trgovačkom centru Greenwood Park, izvijestile su novine Indianapolis Star.</p>
    <p>Napadač je bio sam i imao je pušku te nekoliko spremnika streljiva, navode novine.</p>
    <p>Napad se dogodio usred zabrinutosti javnosti zbog pucnjava u SAD-u u školama, na radnim mjestima i na javnim mjestima, koje redovito dospiju na naslovnice.</p>
    ]]></content:encoded>



        </item>
      </channel>
    </rss>
    """
  end

  defp article_payload do
    File.read!("test/support/payloads/prva_smjena_scraper/article.html")
  end
end
