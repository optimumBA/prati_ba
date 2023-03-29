defmodule PratiBaWeb.AdminController do
  use PratiBaWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: ~p"/admin/dashboard")
  end
end
