defmodule PratiBaWeb.AnalyticsLive.Index do
  use PratiBaWeb, :live_view

  alias PratiBa.Analytics.{Event, Visit}
  alias PratiBa.Repo
  alias PratiBaWeb.Presence
  alias PratiBaWeb.AnalyticsView

  @topic "analytics"

  @impl true
  def mount(_params, _session, socket) do
    PratiBaWeb.Endpoint.subscribe(@topic)

    Presence.track(
      self(),
      @topic,
      socket.id,
      %{}
    )

    socket =
      socket
      |> count_current_visitors()
      |> fetch_data()

    schedule_refresh()

    {:ok, socket}
  end

  @impl true
  def render(assigns), do: AnalyticsView.render("index.html", assigns)

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{assigns: %{current_visitors_count: count}} = socket
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

    {:noreply, assign(socket, :current_visitors_count, visitors_count)}
  end

  def handle_info(:refresh, socket) do
    socket = fetch_data(socket)

    schedule_refresh()

    {:noreply, socket}
  end

  defp count_current_visitors(socket) do
    initial_count =
      @topic
      |> Presence.list()
      |> Enum.filter(&is_visitor?/1)
      |> length()

    assign(socket, :current_visitors_count, initial_count)
  end

  defp is_visitor?({"phx-" <> _, _}), do: false
  defp is_visitor?(_), do: true

  defp fetch_data(socket) do
    visitors_count =
      Visit
      |> Visit.last_week()
      |> Visit.unique()
      |> Repo.aggregate(:count)

    visitors_count_before =
      Visit
      |> Visit.week_before_last()
      |> Visit.unique()
      |> Repo.aggregate(:count)

    visits_count =
      Visit
      |> Visit.last_week()
      |> Repo.aggregate(:count)

    visits_count_before =
      Visit
      |> Visit.week_before_last()
      |> Repo.aggregate(:count)

    visit_duration =
      Visit
      |> Visit.last_week()
      |> Visit.duration()
      |> Repo.one()
      |> Map.get(:secs)

    visit_duration_before =
      Visit
      |> Visit.week_before_last()
      |> Visit.duration()
      |> Repo.one()
      |> Map.get(:secs)

    article_views_count =
      Event
      |> Event.article_views()
      |> Event.last_week()
      |> Repo.aggregate(:count)

    article_views_count_before =
      Event
      |> Event.article_views()
      |> Event.week_before_last()
      |> Repo.aggregate(:count)

    visitors_per_day =
      Visit.per_day_query()
      |> Repo.query!()
      |> Map.get(:rows)
      |> Jason.encode!()

    socket
    |> assign(:visitors_count, visitors_count)
    |> assign(:visitors_count_before, visitors_count_before)
    |> assign(:visits_count, visits_count)
    |> assign(:visits_count_before, visits_count_before)
    |> assign(:visit_duration, visit_duration)
    |> assign(:visit_duration_before, visit_duration_before)
    |> assign(:article_views_count, article_views_count)
    |> assign(:article_views_count_before, article_views_count_before)
    |> assign(:visitors_per_day, visitors_per_day)
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, 5000)
  end
end
