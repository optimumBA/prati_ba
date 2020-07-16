defmodule PratiBaWeb.Plugs.RequestTrackerTest do
  use PratiBaWeb.ConnCase, async: true

  alias PratiBa.Analytics

  describe "call" do
    test "tracks requests", %{conn: conn} do
      assert length(Analytics.list_visitors()) == 0
      assert length(Analytics.list_requests()) == 0

      conn = get(conn, "/")
      assert length(Analytics.list_visitors()) == 1
      assert [request] = Analytics.list_requests()
      assert conn.private[:request_id] == request.id

      get(conn, "/")
      assert length(Analytics.list_visitors()) == 1
      assert length(Analytics.list_requests()) == 2
    end
  end
end
