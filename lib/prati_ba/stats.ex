defmodule PratiBa.Stats do
  @moduledoc """
  The Stats context.
  """

  alias PratiBa.Repo
  alias PratiBa.Stats.{Request, Visitor}

  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  def list_requests do
    Request
    |> Repo.all()
  end

  @doc """
  Returns the list of visitors.

  ## Examples

      iex> list_visitors()
      [%Visitor{}, ...]

  """
  def list_visitors do
    Visitor
    |> Repo.all()
  end

  def track_request(request_id, visitor_id, conn) do
    visitor = case Repo.get(Visitor, visitor_id) do
      nil ->
        %Visitor{}
        |> Visitor.changeset(%{id: visitor_id})
        |> Repo.insert!()
      visitor ->
        visitor
    end

    attrs = parse_request_data(request_id, conn)

    %Request{}
    |> Request.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:visitor, visitor)
    |> Repo.insert!()
  end

  defp parse_request_data(request_id, conn) do
    headers = Enum.into(conn.req_headers, %{})
    remote_ip = parse_remote_ip(conn)

    {isp, geo} =
      remote_ip
      |> Geolix.lookup()
      |> parse_geo_data()

    user_agent =
      headers["user-agent"]
      |> UAInspector.parse()

    %{
      id: request_id,
      geo: geo,
      isp: isp,
      path: conn.request_path,
      raw: %{
        remote_ip: remote_ip,
        req_headers: headers,
      },
      referer: headers["referer"],
      user_agent: user_agent,
    }
  end

  defp parse_remote_ip(conn) do
    conn.remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp parse_geo_data(nil), do: {nil, nil}
  defp parse_geo_data(map) when map_size(map) == 0, do: {nil, nil}
  defp parse_geo_data(%{asn: asn, city: city}) do
    isp = parse_asn(asn)
    geo = parse_city(city)

    {isp, geo}
  end

  defp parse_asn(nil), do: nil
  defp parse_asn(%{autonomous_system_organization: isp}), do: isp

  defp parse_city(nil), do: nil
  defp parse_city(%{continent: continent, country: country, city: city}) do
    %{
      continent: continent.name,
      country: country.name,
      city: city.name,
    }
  end
end
