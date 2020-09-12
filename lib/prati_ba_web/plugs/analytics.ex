defmodule PratiBaWeb.Plugs.Analytics do
  @behaviour Plug

  import Plug.Conn

  alias Plug.Conn
  alias PratiBa.Analytics
  alias PratiBa.Analytics.{Event, EventType, Parser, Visit, Visitor}

  @ignored_remote_ips MapSet.new([
                        {0, 0, 0, 0, 0, 0, 0, 1}
                      ])

  @ignored_user_agents MapSet.new([
                         "Amazon CloudFront"
                       ])

  def init(_opts), do: nil

  def call(%Conn{} = conn, _opts) do
    user_agent = Plug.Conn.get_req_header(conn, "user-agent") |> List.first()

    if should_ignore?(conn.remote_ip, user_agent) do
      conn
    else
      conn
      |> get_or_create_visitor()
      |> create_or_update_visit()
      |> sign_analytics_token()
      |> track_page_view()
    end
  end

  defp should_ignore?(remote_ip, user_agent) do
    MapSet.member?(@ignored_remote_ips, remote_ip) ||
      MapSet.member?(@ignored_user_agents, user_agent) ||
      UAInspector.bot?(user_agent)
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
        headers = Enum.into(conn.req_headers, %{})
        remote_ip = parse_remote_ip(conn)

        visit_attrs = %{
          last_active_at: now,
          raw: %{
            remote_ip: remote_ip,
            user_agent: headers["user-agent"]
          },
          started_at: now
        }

        case Analytics.create_visit(visitor, visit_attrs) do
          {:ok, visit} ->
            conn =
              conn
              |> put_session(:visit_id, visit.id)
              |> assign(:visit, visit)

            Task.async(fn -> parse_visit_info(visit, remote_ip, headers["user-agent"]) end)

            {conn, visit}

          _ ->
            {conn, nil}
        end
    end
  end

  defp sign_analytics_token({%Conn{} = conn, nil}), do: {conn, nil}

  defp sign_analytics_token(
         {%Conn{} = conn, %Visit{id: visit_id, visitor_id: visitor_id} = visit}
       ) do
    token =
      Phoenix.Token.sign(
        conn,
        Application.get_env(:prati_ba, :socket_salt),
        visitor_id <> ":" <> visit_id
      )

    {assign(conn, :analytics_token, token), visit}
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

  defp parse_remote_ip(conn) do
    conn.remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp parse_visit_info(%Visit{} = visit, remote_ip, user_agent) do
    {isp, location} =
      remote_ip
      |> Parser.parse_ip_address()

    {browser, device, os} =
      user_agent
      |> Parser.parse_user_agent()

    visit_attrs = %{
      browser: browser,
      device: device,
      isp: isp,
      location: location,
      os: os
    }

    Analytics.update_visit(visit, visit_attrs)
  end
end
