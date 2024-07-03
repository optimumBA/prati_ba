defmodule PratiBaWeb.AdminController do
  @moduledoc false

  use PratiBaWeb, :controller

  @type conn :: Plug.Conn.t()

  @spec index(conn(), map()) :: conn()
  def index(conn, _params) do
    redirect(conn, to: ~p"/admin/dashboard")
  end
end
