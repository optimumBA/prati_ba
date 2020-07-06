defmodule PratiBa.ScrapersTest do
  use PratiBa.DataCase, async: true

  import Mox

  alias PratiBa.Articles
  alias PratiBa.Articles.Source
  alias PratiBa.Scrapers
  alias PratiBa.Scrapers.ScraperMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "fetch_new_articles/0 gets new articles and saves them to DB" do
    source_name = "Fake source"
    insert(:source, name: source_name)

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

    ScraperMock
    |> expect(:articles, fn -> {:ok, Stream.map(articles, fn article -> article end)} end)
    |> expect(:article_details, fn article -> {:ok, Map.put(article, :title, "Fake title")} end)
    |> expect(:article_details, fn _ -> {:error, %Mojito.Error{}} end)

    Scrapers.fetch_new_articles(%{source_name => ScraperMock})

    assert [article] = Articles.list_articles()
    assert article.image == nil
    assert article.original_id == "1234"
    assert article.published_at == ~N[2020-03-11 18:49:00]
    assert article.title == "Fake title"
    assert article.url == "https://fakesour.ce/fake-title"
    assert %Source{name: "Fake source"} = article.source
  end

  test "fetch_new_articles/0 doesn't crash when there are network issues" do
    source_name = "Fake source"
    insert(:source, name: source_name)

    ScraperMock
    |> expect(:articles, fn -> {:error, %Mojito.Error{}} end)

    Scrapers.fetch_new_articles(%{source_name => ScraperMock})

    assert [] = Articles.list_articles()
  end

  test "fetch_new_articles/0 doesn't crash when the scraper module is not defined" do
    source_name = "Fake source"
    insert(:source, name: source_name)

    Scrapers.fetch_new_articles(%{})

    assert [] = Articles.list_articles()
  end
end
