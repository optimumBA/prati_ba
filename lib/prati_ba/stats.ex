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
    visitor =
      case Repo.get(Visitor, visitor_id) do
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

    %{
      id: request_id,
      geo: nil,
      isp: nil,
      path: conn.request_path,
      raw: %{
        remote_ip: remote_ip,
        req_headers: headers
      },
      referer: headers["referer"],
      user_agent: nil
    }
  end

  defp parse_remote_ip(conn) do
    conn.remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end
end
