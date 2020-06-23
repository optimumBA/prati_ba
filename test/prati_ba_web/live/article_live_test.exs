defmodule PratiBaWeb.ArticleLiveTest do
  use PratiBaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PratiBa.Articles

  defp create_article(_) do
    category = insert(:category, name: "Category with articles")
    insert(:article, title: "First article", category: category, published_at: ~N[2020-04-23 19:12:00])
    insert(:article, title: "Second article", category: category, published_at: ~N[2020-04-23 19:20:00])
    empty_category = insert(:category, name: "Empty category")
    %{empty_category: empty_category}
  end

  defp create_source(_) do
    %{source: insert(:source)}
  end

  describe "Index" do
    setup [:create_article, :create_source]

    test "lists all articles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.article_index_path(conn, :index))

      assert html =~ "Prati.ba"
      assert html =~ "Category with articles"
      refute html =~ "Empty category"
      articles = Regex.scan(~r/<div class=\"article-title\">([^<]+)<\/div>/, html)
      assert [[_, "Second article"], [_, "First article"]] = articles
    end

    test "gets updated with new articles", %{conn: conn, empty_category: category, source: source} do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))
      refute has_element?(index_live, "#category-#{category.id}", "Empty category")

      attrs = %{build(:article) | category: category.name} |> Map.from_struct()
      {:ok, article} = Articles.create_article(source, attrs)

      assert has_element?(index_live, "#category-#{category.id}", "Empty category")
      assert has_element?(index_live, "#article-#{article.id}", article.title)
    end
  end
end
