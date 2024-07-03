defmodule PratiBaWeb.AnalyticsChannelTest do
  use PratiBaWeb.ChannelCase, async: true

  alias PratiBa.Analytics

  setup do
    visitor = PratiBa.Factory.insert(:visitor)
    visit = insert(:visit, visitor: visitor)

    {:ok, _other, socket} =
      PratiBaWeb.UserSocket
      |> socket(nil, %{visitor: visitor, visit: visit})
      |> subscribe_and_join(PratiBaWeb.AnalyticsChannel, "analytics")

    %{socket: socket}
  end

  test "saves visit details", %{socket: socket} do
    ref =
      push(socket, "details", %{
        "browserWidth" => 1280,
        "browserHeight" => 648,
        "siteLanguage" => "en",
        "screenWidth" => 1280,
        "screenHeight" => 1080,
        "screenColorDepth" => 24
      })

    assert_reply ref, :ok

    visit = Analytics.get_active_visit(socket.assigns[:visitor], socket.assigns[:visit].id)

    assert %{
             "browser_width" => 1280,
             "browser_height" => 648,
             "site_language" => "en",
             "screen_width" => 1280,
             "screen_height" => 1080,
             "screen_color_depth" => 24
           } = visit.raw
  end

  test "ping prolongs visit", %{socket: socket} do
    :timer.sleep(1000)

    ref = push(socket, "ping", nil)
    assert_reply ref, :ok

    updated_visit = Analytics.get_active_visit(socket.assigns.visitor, socket.assigns.visit.id)
    refute updated_visit.last_active_at == socket.assigns.visit.last_active_at
  end
end
