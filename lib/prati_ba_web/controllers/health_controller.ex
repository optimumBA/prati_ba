defmodule PratiBaWeb.HealthController do
  use PratiBaWeb, :controller

  def index(conn, _params) do
    # Return status 500 if unable to connect to DB
    Ecto.Adapters.SQL.query!(PratiBa.Repo, "SELECT 1")

    # Make sure UAInspector and Geolix are ready
    if Application.get_env(:prati_ba, :env) == :prod do
      true = UAInspector.ready?()
      [:city, :asn] = Geolix.Database.Loader.loaded_databases()
    end

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
