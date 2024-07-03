defmodule Mix.Tasks.PratiBa.Analytics.ProcessOldData do
  @shortdoc "Processed old analytics data"

  @moduledoc false

  use Mix.Task

  alias PratiBa.Analytics
  alias PratiBa.Analytics.Parser
  alias PratiBa.Analytics.Visit

  @spec run(any()) :: :ok
  def run(_task) do
    Mix.Task.run("app.start")

    # Wait for Geolix to load DBs
    :timer.sleep(5000)

    Enum.each(Analytics.list_visits(), &process_visit/1)
  end

  defp process_visit(%Visit{raw: %{"remote_ip" => remote_ip, "user_agent" => user_agent}} = visit) do
    {browser, device, os} = Parser.parse_user_agent(user_agent)

    {isp, location} = Parser.parse_ip_address(remote_ip)

    Analytics.update_visit(visit, %{
      browser: browser,
      device: device,
      isp: isp,
      location: location,
      os: os
    })
  end

  defp process_visit(_visit), do: nil
end
