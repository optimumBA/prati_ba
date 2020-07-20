defmodule PratiBa.Analytics.EventType do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_event_types" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(event_type, attrs) do
    event_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
