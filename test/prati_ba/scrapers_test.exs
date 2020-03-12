defmodule PratiBa.ScrapersTest do
  use PratiBa.DataCase, async: true

  import Mox

  alias PratiBa.Articles
  alias PratiBa.Articles.Source
  alias PratiBa.Scrapers
  alias PratiBa.Scrapers.ScraperMock

  setup :verify_on_exit!

  test "fetch_new_articles/0 gets new articles and saves them to DB" do
    source_name = "Fake source"
    insert(:source, name: source_name)

    article = %{
      id: 1234,
      title: "Fake title",
      description: "Description",
      category: "Category",
      published_at: ~N[2020-03-11 18:49:00],
      author: "Author",
      image: %{
        width: nil,
        url: nil,
        credit: nil,
      },
      url: "https://fakesour.ce/fake-title",
    }

    ScraperMock
    |> expect(:source_name, fn -> source_name end)
    |> expect(:articles, fn -> {:ok, [article]} end)

    Scrapers.fetch_new_articles([ScraperMock])

    assert [article] = Articles.list_articles()
    assert article.image == nil
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

    Scrapers.fetch_new_articles([ScraperMock])

    assert [] = Articles.list_articles()
  end
end
