defmodule PratiBaWeb.AdminControllerTest do
  use PratiBaWeb.ConnCase, async: true

  describe "index" do
    test "redirects to the dashboard", %{conn: conn} do
      authorization = "Basic " <> Base.encode64("pratiba:pratiba")

      conn =
        conn
        |> put_req_header("authorization", authorization)
        |> get(~p"/admin")

      assert redirected_to(conn) == "/admin/dashboard"
    end
  end
end
