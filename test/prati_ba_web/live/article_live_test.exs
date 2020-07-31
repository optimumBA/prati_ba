defmodule PratiBaWeb.ArticleLiveTest do
  use PratiBaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PratiBa.Articles

  defp create_article(_) do
    first_article =
      insert(:article, title: "First article", published_at: ~N[2020-04-23 19:12:00])

    second_article =
      insert(:article, title: "Second article", published_at: ~N[2020-04-23 19:20:00])

    %{
      first_article: first_article,
      second_article: second_article
    }
  end

  defp create_source(_) do
    %{source: insert(:source)}
  end

  describe "Index" do
    setup [:create_article, :create_source]

    test "lists all articles", %{
      conn: conn,
      first_article: first_article,
      second_article: second_article
    } do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))

      assert has_element?(index_live, "#article-#{first_article.id}", "First article")
      assert has_element?(index_live, "#article-#{second_article.id}", "Second article")
    end

    test "gets updated with new articles", %{conn: conn, source: source} do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))

      attrs = build(:article, image: "https://via.placeholder.com/350x150") |> Map.from_struct()
      {:ok, article} = Articles.create_article(source, attrs)

      assert has_element?(index_live, "#article-#{article.id}", article.title)
    end
  end
end
