defmodule PratiBa.Analytics.Visitor do
  @moduledoc false

  use Ecto.Schema
  alias PratiBa.Analytics.Visit

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_visitors" do
    has_many :visits, Visit

    timestamps()
  end
end
