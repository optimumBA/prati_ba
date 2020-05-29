defmodule PratiBaWeb.HealthController do
  use PratiBaWeb, :controller

  def index(conn, _params) do
    {_, timestamp} = Timex.format(DateTime.utc_now(), "%FT%T%:z", :strftime)

    json(conn, %{
      status: :ok,
      timestamp: timestamp,
    })
  end
end
