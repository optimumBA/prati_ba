defmodule PratiBa.Analytics.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Analytics.EventType
  alias PratiBa.Analytics.Visit

  @type query :: Ecto.Query.t()
  @type queryable :: Ecto.Queryable.t()
  @type t :: %__MODULE__{}

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
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:details, :finished_at, :requested_at, :started_at])
    |> validate_required([:requested_at])
  end

  @spec article_views(queryable()) :: query()
  def article_views(queryable \\ __MODULE__) do
    from e in queryable,
      join: et in assoc(e, :event_type),
      where: et.name == "article_view"
  end

  @spec last_week(queryable()) :: query()
  def last_week(queryable \\ __MODULE__) do
    from e in queryable,
      where:
        fragment(
          "? BETWEEN (now() AT TIME ZONE 'UTC' - INTERVAL '7 days') AND now()",
          e.requested_at
        )
  end

  @spec week_before_last(queryable()) :: query()
  def week_before_last(queryable \\ __MODULE__) do
    from e in queryable,
      where:
        fragment(
          "? BETWEEN (now() AT TIME ZONE 'UTC' - INTERVAL '14 days') AND (now() AT TIME ZONE 'UTC' - INTERVAL '7 days')",
          e.requested_at
        )
  end
end
