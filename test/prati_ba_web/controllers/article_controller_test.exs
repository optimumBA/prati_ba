defmodule PratiBaWeb.ArticleControllerTest do
  use PratiBaWeb.ConnCase, async: true

  describe "index" do
    test "lists all articles", %{conn: conn} do
      category = insert(:category, name: "Category with articles")
      insert(:article, title: "First article", category: category, published_at: ~N[2020-04-23 19:12:00])
      insert(:article, title: "Second article", category: category, published_at: ~N[2020-04-23 19:20:00])
      insert(:category, name: "Empty category")

      conn = get(conn, Routes.article_path(conn, :index))
      assert html_response(conn, 200) =~ "Prati.ba"
      assert conn.resp_body =~ "Category with articles"
      refute conn.resp_body =~ "Empty category"
      articles = Regex.scan(~r/<div class=\"article-title\">([^<]+)<\/div>/, conn.resp_body)
      assert [[_, "Second article"], [_, "First article"]] = articles
    end
  end
end
