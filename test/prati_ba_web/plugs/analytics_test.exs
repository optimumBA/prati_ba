defmodule PratiBaWeb.Plugs.AnalyticsTest do
  use PratiBaWeb.ConnCase, async: true

  alias PratiBa.Analytics
  alias PratiBa.Analytics.EventType

  describe "call" do
    test "tracks new visitor", %{conn: conn} do
      assert length(Analytics.list_visitors()) == 0

      conn = get(conn, "/")

      assert [visitor] = Analytics.list_visitors()
      assert get_session(conn, :visitor_id) == visitor.id

      assert [visit] = Analytics.list_visits()
      assert get_session(conn, :visit_id) == visit.id
      assert conn.assigns[:visit] == visit
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

      conn = Plug.Test.init_test_session(conn, visitor_id: visitor.id, visit_id: visit.id)
      conn = get(conn, "/")

      assert [^visitor] = Analytics.list_visitors()
      assert [^visit, new_visit] = Analytics.list_visits()

      assert get_session(conn, :visit_id) == new_visit.id
      assert conn.assigns[:visit] == new_visit
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

      conn = Plug.Test.init_test_session(conn, visitor_id: visitor.id, visit_id: visit.id)
      conn = get(conn, "/")

      assert get_session(conn, :visitor_id) == visitor.id
      assert get_session(conn, :visit_id) == visit.id
      assert conn.assigns[:visit].id == visit.id
      assert length(Analytics.list_visitors()) == 1
      assert [returned_visit] = Analytics.list_visits()
      refute returned_visit.last_active_at == returned_visit.started_at
    end

    test "tracks page view", %{conn: conn} do
      assert length(Analytics.list_events()) == 0

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
  end
end
