defmodule PratiBaWeb.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :prati_ba,
    pubsub_server: PratiBa.PubSub
end
