defmodule PratiBaWeb.Plugs.Analytics do
  @behaviour Plug

  import Plug.Conn

  alias Plug.Conn
  alias PratiBa.Analytics
  alias PratiBa.Analytics.{Event, EventType, Visit, Visitor}

  def init(_opts), do: nil

  def call(%Conn{} = conn, _opts) do
    conn
    |> get_or_create_visitor()
    |> create_or_update_visit()
    |> track_page_view()
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

  defp create_or_update_visit({%Conn{} = conn, nil}), do: {conn, nil}

  defp create_or_update_visit({%Conn{} = conn, %Visitor{} = visitor}) do
    now = NaiveDateTime.utc_now()

    with visit_id = get_session(conn, :visit_id),
         false <- is_nil(visit_id),
         visit = Analytics.get_active_visit(visitor, visit_id),
         false <- is_nil(visit) do
      Analytics.update_visit(visit, %{
        last_active_at: now
      })

      {assign(conn, :visit, visit), visit}
    else
      _ ->
        visit_attrs = %{
          started_at: now,
          last_active_at: now
        }

        case Analytics.create_visit(visitor, visit_attrs) do
          {:ok, visit} ->
            conn =
              conn
              |> put_session(:visit_id, visit.id)
              |> assign(:visit, visit)

            {conn, visit}

          _ ->
            {conn, nil}
        end
    end
  end

  defp track_page_view({%Conn{} = conn, nil}), do: conn

  defp track_page_view({%Conn{} = conn, %Visit{} = visit}) do
    case Analytics.get_event_type("page_view") do
      %EventType{} = event_type ->
        headers = Enum.into(conn.req_headers, %{})

        case Analytics.create_event(visit, event_type, %{
               details: %{
                 path: conn.request_path,
                 referer: headers["referer"]
               },
               requested_at: NaiveDateTime.utc_now()
             }) do
          {:ok, %Event{} = event} ->
            events = Map.get(conn.assigns, :events, [])
            assign(conn, :events, [event | events])

          {:error, _reason} ->
            conn
        end

      _ ->
        conn
    end
  end
end
