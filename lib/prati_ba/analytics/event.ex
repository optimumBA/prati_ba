defmodule PratiBa.Analytics.Event do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

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

  def article_views(queryable \\ __MODULE__) do
    from e in queryable,
      join: et in assoc(e, :event_type),
      where: et.name == "article_view"
  end

  def last_week(queryable \\ __MODULE__) do
    from e in queryable,
      where:
        fragment(
          "? BETWEEN (now() AT TIME ZONE 'UTC' - INTERVAL '7 days') AND now()",
          e.requested_at
        )
  end

  def week_before_last(queryable \\ __MODULE__) do
    from e in queryable,
      where:
        fragment(
          "? BETWEEN (now() AT TIME ZONE 'UTC' - INTERVAL '14 days') AND (now() AT TIME ZONE 'UTC' - INTERVAL '7 days')",
          e.requested_at
        )
  end
end
