defmodule PratiBaWeb.Plugs.RequestTrackerTest do
  use PratiBaWeb.ConnCase, async: true

  alias PratiBa.Stats

  describe "call" do
    test "tracks requests", %{conn: conn} do
      assert length(Stats.list_visitors()) == 0
      assert length(Stats.list_requests()) == 0

      conn = get(conn, "/")
      assert length(Stats.list_visitors()) == 1
      assert [request] = Stats.list_requests()
      assert conn.private[:request_id] == request.id

      get(conn, "/")
      assert length(Stats.list_visitors()) == 1
      assert length(Stats.list_requests()) == 2
    end
  end
end
