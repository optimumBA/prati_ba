defmodule PratiBaWeb.ArticleControllerTest do
  use PratiBaWeb.ConnCase

  describe "index" do
    test "lists all articles", %{conn: conn} do
      category = insert(:category)
      insert(:article, title: "First article", category: category)
      insert(:article, title: "Second article", category: category)

      conn = get(conn, Routes.article_path(conn, :index))
      assert html_response(conn, 200) =~ "First article"
      assert html_response(conn, 200) =~ "Second article"
    end
  end
end
