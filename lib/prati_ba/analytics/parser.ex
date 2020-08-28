defmodule PratiBa.Analytics.Parser do
  def parse_user_agent(user_agent) do
    ua =
      user_agent
      |> UAInspector.parse_client()

    {maybe_convert(ua.client), maybe_convert(ua.device), maybe_convert(ua.os)}
  end

  def parse_ip_address(remote_ip) do
    remote_ip
    |> Geolix.lookup()
    |> parse_geo_data()
  end

  defp maybe_convert(:unknown), do: nil
  defp maybe_convert(%{} = struct), do: Map.from_struct(struct)
  defp maybe_convert(_), do: nil

  defp parse_geo_data(nil), do: {nil, nil}
  defp parse_geo_data(map) when map_size(map) == 0, do: {nil, nil}

  defp parse_geo_data(%{asn: asn, city: city}) do
    isp = parse_asn(asn)
    location = parse_city(city)

    {isp, location}
  end

  defp parse_asn(nil), do: nil
  defp parse_asn(%{autonomous_system_organization: isp}), do: isp

  defp parse_city(nil), do: nil

  defp parse_city(%{continent: continent, country: country, city: city}) do
    %{
      continent: get_name(continent),
      country: get_name(country),
      city: get_name(city)
    }
  end

  defp get_name(nil), do: nil
  defp get_name(%{name: name}), do: name
end
