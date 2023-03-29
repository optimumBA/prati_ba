defmodule PratiBa.ScrapingPipelineTest do
  use PratiBa.DataCase, async: false

  import Mox

  alias PratiBa.{Articles, Scrapers, ScrapingPipeline}

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "gets new articles and saves them to DB" do
    source_name = "Fake source"
    insert(:source, name: source_name)
    Application.put_env(:prati_ba, :scrapers, %{source_name => Scrapers.ScraperMock})

    articles = [
      %{
        original_id: "1234",
        title: nil,
        description: "Description",
        published_at: ~N[2020-03-11 18:49:00],
        author: "Author",
        image: nil,
        url: "https://fakesour.ce/fake-title"
      },
      %{
        original_id: "15",
        title: nil,
        description: "Description",
        published_at: ~N[2020-04-21 14:37:00],
        author: "Author",
        image: nil,
        url: "https://fakesour.ce/another-article"
      }
    ]

    Scrapers.ScraperMock
    |> expect(:articles, fn -> {:ok, Stream.map(articles, fn article -> article end)} end)
    |> expect(:article_details, fn article ->
      {:ok, Map.merge(article, %{title: "Fake title", image: "https://placekitten.com/350/150"})}
    end)
    |> expect(:article_details, fn _ -> {:error, %Finch.Error{}} end)

    ScrapingPipeline.start()
    :timer.sleep(100)

    assert [article] = Articles.list_articles()
    refute is_nil(article.image)
    assert article.original_id == "1234"
    assert article.published_at == ~N[2020-03-11 18:49:00]
    assert article.title == "Fake title"
    assert article.url == "https://fakesour.ce/fake-title"
    assert %Articles.Source{name: "Fake source"} = article.source
  end

  test "doesn't crash when there are network issues" do
    pid = Process.whereis(ScrapingPipeline)
    source_name = "Fake source"
    insert(:source, name: source_name)
    Application.put_env(:prati_ba, :scrapers, %{source_name => Scrapers.ScraperMock})

    Scrapers.ScraperMock
    |> expect(:articles, fn -> {:error, %Finch.Error{}} end)

    ScrapingPipeline.start()
    :timer.sleep(100)

    assert [] = Articles.list_articles()
    assert Process.whereis(ScrapingPipeline) == pid
  end

  test "doesn't crash when the scraper module is not defined" do
    pid = Process.whereis(ScrapingPipeline)
    source_name = "Fake source"
    insert(:source, name: source_name)
    Application.put_env(:prati_ba, :scrapers, %{})

    ScrapingPipeline.start()
    :timer.sleep(100)

    assert [] = Articles.list_articles()
    assert Process.whereis(ScrapingPipeline) == pid
  end
end
