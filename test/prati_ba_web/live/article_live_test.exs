defmodule PratiBaWeb.ArticleLiveTest do
  use PratiBaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PratiBa.Articles

  defp create_article(_) do
    category = insert(:category, name: "Category with articles")
    first_article = insert(:article, title: "First article", category: category, published_at: ~N[2020-04-23 19:12:00])
    second_article = insert(:article, title: "Second article", category: category, published_at: ~N[2020-04-23 19:20:00])
    empty_category = insert(:category, name: "Empty category")

    %{
      category: category,
      empty_category: empty_category,
      first_article: first_article,
      second_article: second_article,
    }
  end

  defp create_source(_) do
    %{source: insert(:source)}
  end

  describe "Index" do
    setup [:create_article, :create_source]

    test "lists all articles", %{
      conn: conn,
      category: category,
      empty_category: empty_category,
      first_article: first_article,
      second_article: second_article,
    } do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))

      assert has_element?(index_live, "#article-#{first_article.id}", "First article")
      assert has_element?(index_live, "#article-#{second_article.id}", "Second article")
      refute has_element?(index_live, "#category-#{category.id}", "Category with articles")

      index_live
      |> element(".group-control", "Po kategorijama")
      |> render_click()

      assert has_element?(index_live, "#category-#{category.id}", "Category with articles")
      refute has_element?(index_live, "#category-#{empty_category.id}", "Empty category")
      assert has_element?(index_live, "#article-#{first_article.id}", "First article")
      assert has_element?(index_live, "#article-#{second_article.id}", "Second article")
    end

    test "gets updated with new articles", %{
      conn: conn,
      category: category,
      empty_category: empty_category,
      source: source,
    } do
      {:ok, index_live, _html} = live(conn, Routes.article_index_path(conn, :index))

      attrs = build(:article, category: category.name) |> Map.from_struct()
      {:ok, article} = Articles.create_article(source, attrs)

      assert has_element?(index_live, "#article-#{article.id}", article.title)

      index_live
        |> element(".group-control", "Po kategorijama")
        |> render_click()

      refute has_element?(index_live, "#category-#{empty_category.id}", "Empty category")

      attrs = %{build(:article) | category: empty_category.name} |> Map.from_struct()
      {:ok, article} = Articles.create_article(source, attrs)

      assert has_element?(index_live, "#category-#{empty_category.id}", "Empty category")
      assert has_element?(index_live, "#article-#{article.id}", article.title)
    end
  end
end
