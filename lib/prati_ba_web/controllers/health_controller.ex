defmodule PratiBaWeb.HealthController do
  use PratiBaWeb, :controller

  def index(conn, _params) do
    {_, timestamp} = Timex.format(DateTime.utc_now(), "%FT%T%:z", :strftime)

    {:ok, hostname} = :inet.gethostname()

    json(conn, %{
      connected_to: Node.list(),
      hostname: to_string(hostname),
      node: Node.self(),
      status: :ok,
      timestamp: timestamp
    })
  end
end
