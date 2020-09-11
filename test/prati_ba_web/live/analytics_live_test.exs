defmodule PratiBaWeb.AnalyticsLiveTest do
  use PratiBaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Phoenix.ChannelTest

  defp authorize(%{conn: conn}) do
    authorization = "Basic " <> Base.encode64("pratiba:pratiba")

    conn =
      conn
      |> put_req_header("authorization", authorization)

    %{conn: conn}
  end

  describe "Index" do
    setup [:authorize]

    test "shows number of visitors", %{conn: conn} do
      {:ok, index_live, html} = live(conn, Routes.analytics_index_path(conn, :index))

      visitor = insert(:visitor)
      visit = insert(:visit, visitor: visitor)

      assert html =~ "0 current visitors"

      {:ok, _, socket} =
        PratiBaWeb.UserSocket
        |> socket(nil, %{visitor: visitor, visit: visit})
        |> subscribe_and_join(PratiBaWeb.AnalyticsChannel, "analytics")

      # Prevent test crashing
      Process.unlink(socket.channel_pid)

      assert has_element?(index_live, "main", "1 current visitor")

      close(socket)
      :timer.sleep(1)

      assert has_element?(index_live, "main", "0 current visitors")
    end
  end
end
