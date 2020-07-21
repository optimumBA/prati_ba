defmodule PratiBa.Analytics.Event do
  use Ecto.Schema

  import Ecto.Changeset

  alias PratiBa.Analytics.{EventType, Visit}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_events" do
    field :details, :map
    field :finished_at, :naive_datetime
    field :requested_at, :naive_datetime
    field :started_at, :naive_datetime
    belongs_to :event_type, EventType
    belongs_to :visit, Visit

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:details, :finished_at, :requested_at, :started_at])
    |> validate_required([:requested_at])
  end
end
