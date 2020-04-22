defmodule PratiBaWeb.Plugs.RequestTracker do
  @behaviour Plug

  import Plug.Conn

  alias PratiBa.Stats

  def init(_opts), do: nil

  def call(conn, _opts) do
    request_id = Ecto.UUID.generate()
    conn = put_private(conn, :request_id, request_id)

    {conn, visitor_id} = case get_session(conn, :visitor_id) do
      nil ->
        visitor_id = Ecto.UUID.generate()
        conn = put_session(conn, :visitor_id, visitor_id)
        {conn, visitor_id}
      visitor_id ->
        {conn, visitor_id}
    end

    Task.async(fn ->
      Stats.track_request(request_id, visitor_id, conn)
    end)

    conn
  end
end
