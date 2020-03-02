defmodule PratiBa.Repo do
  use Ecto.Repo,
    otp_app: :prati_ba,
    adapter: Ecto.Adapters.Postgres
end
