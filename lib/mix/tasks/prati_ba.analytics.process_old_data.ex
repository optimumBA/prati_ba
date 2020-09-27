defmodule Mix.Tasks.PratiBa.Analytics.ProcessOldData do
  use Mix.Task

  @shortdoc "Processed old analytics data"

  alias PratiBa.Analytics
  alias PratiBa.Analytics.{Parser, Visit}

  def run(_) do
    Mix.Task.run("app.start")

    # Wait for Geolix to load DBs
    :timer.sleep(5000)

    Enum.each(Analytics.list_visits(), &process_visit/1)
  end

  defp process_visit(%Visit{raw: %{"remote_ip" => remote_ip, "user_agent" => user_agent}} = visit) do
    {browser, device, os} =
      user_agent
      |> Parser.parse_user_agent()

    {isp, location} =
      remote_ip
      |> Parser.parse_ip_address()

    Analytics.update_visit(visit, %{
      browser: browser,
      device: device,
      isp: isp,
      location: location,
      os: os
    })
  end

  defp process_visit(_), do: nil
end
