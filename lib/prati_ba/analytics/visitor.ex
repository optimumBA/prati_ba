defmodule PratiBa.Analytics.Visitor do
  use Ecto.Schema
  alias PratiBa.Analytics.Visit

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_visitors" do
    has_many :visits, Visit

    timestamps()
  end
end
