defmodule PratiBaWeb.AdminController do
  use PratiBaWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.live_dashboard_path(conn, :home))
  end
end
