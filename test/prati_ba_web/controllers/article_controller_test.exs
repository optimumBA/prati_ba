defmodule PratiBaWeb.ArticleControllerTest do
  use PratiBaWeb.ConnCase, async: true

  alias PratiBa.Analytics
  alias PratiBa.Analytics.{Event, EventType}

  describe "show" do
    setup %{conn: conn} do
      article = insert(:article, url: "http://sour.ce/article")
      insert(:event_type, name: "article_view")

      {:ok, conn: conn, article: article}
    end

    test "redirects to article page", %{conn: conn, article: article} do
      conn =
        conn
        |> get(Routes.article_path(conn, :show, article))

      assert redirected_to(conn) == "http://sour.ce/article"
    end

    test "tracks article view", %{conn: conn, article: article} do
      get(conn, Routes.article_path(conn, :show, article))

      events = Analytics.list_events()
      assert length(events) == 2
      assert event = Enum.fetch!(events, -1)

      assert %Event{
               details: %{
                 "id" => event_article_id
               },
               event_type: %EventType{
                 name: "article_view"
               }
             } = event

      assert event_article_id == article.id
    end

    test "doesn't crash when bot opens article", %{conn: conn, article: article} do
      conn =
        conn
        |> Plug.Test.init_test_session(visitor_id: nil, visit_id: nil)
        |> put_req_header(
          "user-agent",
          "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
        )

      conn =
        conn
        |> get(Routes.article_path(conn, :show, article))

      assert redirected_to(conn) == "http://sour.ce/article"
    end
  end
end
