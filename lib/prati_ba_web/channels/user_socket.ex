defmodule PratiBaWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", PratiBaWeb.RoomChannel
  channel "analytics", PratiBaWeb.AnalyticsChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    salt = Application.get_env(:prati_ba, :socket_salt)

    case Phoenix.Token.verify(socket, salt, token, max_age: 1_209_600) do
      {:ok, result} ->
        [visitor_id, request_id] =
          result
          |> String.split(":")

        socket =
          socket
          |> assign(:visitor_id, visitor_id)
          |> assign(:request_id, request_id)

        {:ok, socket}

      {:error, _reason} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PratiBaWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
