defmodule PratiBaWeb.AnalyticsLive.Index do
  use PratiBaWeb, :live_view

  alias PratiBaWeb.Presence
  alias PratiBaWeb.AnalyticsView

  @topic "analytics"

  @impl true
  def mount(_params, _session, socket) do
    initial_count =
      @topic
      |> Presence.list()
      |> Enum.filter(&is_visitor?/1)
      |> length()

    PratiBaWeb.Endpoint.subscribe(@topic)

    Presence.track(
      self(),
      @topic,
      socket.id,
      %{}
    )

    {:ok, assign(socket, :visitors_count, initial_count)}
  end

  @impl true
  def render(assigns), do: AnalyticsView.render("index.html", assigns)

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{visitors_count: count}} = socket
      ) do
    joins_count =
      joins
      |> Enum.filter(&is_visitor?/1)
      |> length()

    leaves_count =
      leaves
      |> Enum.filter(&is_visitor?/1)
      |> length()

    visitors_count = count + joins_count - leaves_count

    {:noreply, assign(socket, :visitors_count, visitors_count)}
  end

  defp is_visitor?({"phx-" <> _, _}), do: false
  defp is_visitor?(_), do: true
end
