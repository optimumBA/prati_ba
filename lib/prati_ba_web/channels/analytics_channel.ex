defmodule PratiBaWeb.AnalyticsChannel do
  @moduledoc false

  use PratiBaWeb, :channel

  alias PratiBa.Analytics
  alias PratiBaWeb.Presence

  @topic "analytics"

  intercept ["presence_diff"]

  @impl Phoenix.Channel
  def join(@topic, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl Phoenix.Channel
  def handle_in("details", payload, socket) do
    %{
      "siteLanguage" => site_language,
      "screenWidth" => screen_width,
      "screenHeight" => screen_height,
      "screenColorDepth" => screen_color_depth,
      "browserWidth" => browser_width,
      "browserHeight" => browser_height
    } = payload

    raw =
      socket.assigns.visit
      |> Map.get(:raw)
      |> Map.merge(%{
        site_language: site_language,
        screen_width: screen_width,
        screen_height: screen_height,
        screen_color_depth: screen_color_depth,
        browser_width: browser_width,
        browser_height: browser_height
      })

    Analytics.update_visit(socket.assigns.visit, %{raw: raw})

    {:reply, :ok, socket}
  end

  @impl Phoenix.Channel
  def handle_in("ping", _other, socket) do
    Analytics.update_visit(socket.assigns.visit, %{last_active_at: NaiveDateTime.utc_now()})

    {:reply, :ok, socket}
  end

  @impl Phoenix.Channel
  def handle_info(:after_join, socket) do
    {:ok, _other} = Presence.track(socket, socket.assigns.visit.id, %{})

    {:noreply, socket}
  end

  @impl Phoenix.Channel
  def handle_out("presence_diff", _other, socket), do: {:noreply, socket}
end
