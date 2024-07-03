defmodule PratiBaWeb.Plugs.AnalyticsTest do
  use PratiBaWeb.ConnCase, async: true

  alias PratiBa.Analytics
  alias PratiBa.Analytics.EventType

  describe "call" do
    test "tracks new visitor", %{conn: conn} do
      assert Enum.empty?(Analytics.list_visitors())

      conn =
        conn
        |> put_req_header(
          "user-agent",
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
        )
        |> get("/")

      assert [visitor] = Analytics.list_visitors()
      assert get_session(conn, :visitor_id) == visitor.id

      assert [visit] = Analytics.list_visits()
      assert get_session(conn, :visit_id) == visit.id
      assert conn.assigns[:visit].id == visit.id

      assert %{
               "remote_ip" => "127.0.0.1",
               "user_agent" =>
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
             } = visit.raw
    end

    test "recognizes visitor and creates new visit if current is too old", %{conn: conn} do
      eleven_minutes_ago =
        DateTime.utc_now()
        |> DateTime.add(-11 * 60)
        |> DateTime.to_naive()

      {:ok, visitor} = Analytics.create_visitor()

      {:ok, visit} =
        Analytics.create_visit(visitor, %{
          started_at: eleven_minutes_ago,
          last_active_at: eleven_minutes_ago
        })

      conn =
        conn
        |> Plug.Test.init_test_session(visitor_id: visitor.id, visit_id: visit.id)
        |> put_req_header(
          "user-agent",
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
        )
        |> get("/")

      assert [^visitor] = Analytics.list_visitors()
      assert [^visit, new_visit] = Analytics.list_visits()

      assert get_session(conn, :visit_id) == new_visit.id
      assert conn.assigns[:visit].id == new_visit.id

      assert %{
               "remote_ip" => "127.0.0.1",
               "user_agent" =>
                 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15"
             } = new_visit.raw
    end

    test "recognizes current visit", %{conn: conn} do
      five_minutes_ago =
        DateTime.utc_now()
        |> DateTime.add(-5 * 60)
        |> DateTime.to_naive()

      {:ok, visitor} = Analytics.create_visitor()

      {:ok, visit} =
        Analytics.create_visit(visitor, %{
          started_at: five_minutes_ago,
          last_active_at: five_minutes_ago
        })

      updated_conn =
        conn
        |> Plug.Test.init_test_session(visitor_id: visitor.id, visit_id: visit.id)
        |> get("/")

      assert get_session(updated_conn, :visitor_id) == visitor.id
      assert get_session(updated_conn, :visit_id) == visit.id
      assert updated_conn.assigns[:visit].id == visit.id
      assert length(Analytics.list_visitors()) == 1
      assert [returned_visit] = Analytics.list_visits()
      refute returned_visit.last_active_at == returned_visit.started_at
    end

    test "tracks page view", %{conn: conn} do
      assert Enum.empty?(Analytics.list_events())

      conn = get(conn, "/")

      assert [event] = Analytics.list_events()
      assert %EventType{name: "page_view"} = event.event_type

      assert %{
               "path" => "/",
               "referer" => nil
             } = event.details

      assert [assigned_event] = conn.assigns[:events]
      assert assigned_event.id == event.id
    end

    test "signs token containing visitor and visit IDs", %{conn: conn} do
      visitor = insert(:visitor)
      visit = insert(:visit, visitor: visitor)

      conn =
        conn
        |> Plug.Test.init_test_session(visitor_id: visitor.id, visit_id: visit.id)
        |> get("/")

      assert {:ok, result} =
               Phoenix.Token.verify(
                 conn,
                 Application.get_env(:prati_ba, :socket_salt),
                 conn.assigns[:analytics_token],
                 max_age: 1_209_600
               )

      assert [visitor_id, visit_id] = String.split(result, ":")
      assert visitor_id == visitor.id
      assert visit_id == visit.id
    end
  end

  test "avoids tracking bots", %{conn: conn} do
    assert Enum.empty?(Analytics.list_visitors())

    conn =
      conn
      |> Plug.Test.init_test_session(visitor_id: nil, visit_id: nil)
      |> put_req_header(
        "user-agent",
        "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
      )
      |> get("/")

    assert Enum.empty?(Analytics.list_visitors())
    assert Enum.empty?(Analytics.list_visits())
    assert is_nil(get_session(conn, :visitor_id))
    assert is_nil(get_session(conn, :visit_id))
  end
end
