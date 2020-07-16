defmodule PratiBaWeb.AnalyticsChannel do
  use PratiBaWeb, :channel

  alias PratiBaWeb.Presence

  @topic "analytics"

  intercept ["presence_diff"]

  @impl true
  def join(@topic, _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.visitor_id, %{
        request_id: socket.assigns.request_id
      })

    {:noreply, socket}
  end

  @impl true
  def handle_out("presence_diff", _, socket), do: {:noreply, socket}
end
