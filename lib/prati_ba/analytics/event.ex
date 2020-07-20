defmodule PratiBa.Analytics.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_events" do
    field :details, :map
    field :finished_at, :naive_datetime
    field :requested_at, :naive_datetime
    field :started_at, :naive_datetime
    field :event_type, :binary_id
    field :visit, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:details, :requested_at, :started_at, :finished_at])
    |> validate_required([:details, :requested_at, :started_at, :finished_at])
  end
end
