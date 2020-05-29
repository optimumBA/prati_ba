defmodule PratiBaWeb.HealthControllerTest do
  use PratiBaWeb.ConnCase, async: true

  describe "index" do
    test "returns cluster info", %{conn: conn} do
      conn = get(conn, Routes.health_path(conn, :index))
      assert %{
        "status"       => "ok",
        "timestamp"    => _,
      } = json_response(conn, 200)
    end
  end
end
