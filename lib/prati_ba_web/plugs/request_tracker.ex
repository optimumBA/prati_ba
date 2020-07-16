defmodule PratiBaWeb.Plugs.RequestTracker do
  @behaviour Plug

  import Plug.Conn

  alias PratiBa.Analytics

  def init(_opts), do: nil

  def call(conn, _opts) do
    request_id = Ecto.UUID.generate()
    conn = put_private(conn, :request_id, request_id)

    {conn, visitor_id} =
      case get_session(conn, :visitor_id) do
        nil ->
          visitor_id = Ecto.UUID.generate()
          conn = put_session(conn, :visitor_id, visitor_id)
          {conn, visitor_id}

        visitor_id ->
          {conn, visitor_id}
      end

    analytics_token =
      Phoenix.Token.sign(conn, Application.get_env(:prati_ba, :socket_salt), visitor_id <> ":" <> request_id)

    conn = assign(conn, :analytics_token, analytics_token)

    task =
      Task.async(fn ->
        Analytics.track_request(request_id, visitor_id, requested_at, conn)
      end)

    if Application.get_env(:prati_ba, :env) == :test do
      Task.await(task)
    end

    conn
  end
end
