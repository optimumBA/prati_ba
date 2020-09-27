defmodule PratiBaWeb.Presence do
  use Phoenix.Presence,
    otp_app: :prati_ba,
    pubsub_server: PratiBa.PubSub
end
