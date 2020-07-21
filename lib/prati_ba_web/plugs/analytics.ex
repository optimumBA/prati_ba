defmodule PratiBaWeb.Plugs.Analytics do
  @behaviour Plug

  import Plug.Conn

  alias Plug.Conn
  alias PratiBa.Analytics
  alias PratiBa.Analytics.Visitor

  def init(_opts), do: nil

  def call(%Conn{} = conn, _opts) do
    conn
    |> get_or_create_visitor()
    |> create_or_update_visit()
  end

  defp get_or_create_visitor(%Conn{} = conn) do
    with visitor_id = get_session(conn, :visitor_id),
         false <- is_nil(visitor_id),
         visitor = Analytics.get_visitor(visitor_id),
         false <- is_nil(visitor) do
      {conn, visitor}
    else
      _ ->
        case Analytics.create_visitor() do
          {:ok, %Visitor{} = visitor} ->
            conn = put_session(conn, :visitor_id, visitor.id)
            {conn, visitor}

          {:error, _changeset} ->
            {conn, nil}
        end
    end
  end

  defp create_or_update_visit({conn, nil}), do: conn

  defp create_or_update_visit({%Conn{} = conn, %Visitor{} = visitor}) do
    now = NaiveDateTime.utc_now()

    with visit_id = get_session(conn, :visit_id),
         false <- is_nil(visit_id),
         visit = Analytics.get_active_visit(visitor, visit_id),
         false <- is_nil(visit) do
      Analytics.update_visit(visit, %{
        last_active_at: now
      })

      conn
    else
      _ ->
        visit_attrs = %{
          started_at: now,
          last_active_at: now
        }

        case Analytics.create_visit(visitor, visit_attrs) do
          {:ok, visit} -> conn |> put_session(:visit_id, visit.id)
          _ -> conn
        end
    end
  end
end
