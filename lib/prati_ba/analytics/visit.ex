defmodule PratiBa.Analytics.Visit do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Analytics.Visitor

  @type query :: Ecto.Query.t()
  @type queryable :: Ecto.Queryable.t()
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_visits" do
    field :browser, :map
    field :device, :map
    field :isp, :string
    field :language, :string
    field :last_active_at, :naive_datetime
    field :location, :map
    field :os, :map
    field :raw, :map, default: %{}
    field :size, :string
    field :started_at, :naive_datetime
    belongs_to :visitor, Visitor

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [
      :browser,
      :device,
      :isp,
      :language,
      :last_active_at,
      :location,
      :os,
      :raw,
      :size,
      :started_at
    ])
    |> validate_required([
      :last_active_at,
      :started_at
    ])
  end

  @spec active(queryable()) :: query()
  def active(queryable \\ __MODULE__) do
    from v in queryable,
      where: fragment("? > now() AT TIME ZONE 'UTC' - INTERVAL '10 minutes'", v.last_active_at)
  end

  @spec last_week(queryable()) :: query()
  def last_week(queryable \\ __MODULE__) do
    from v in queryable,
      where:
        fragment(
          "? BETWEEN (now() AT TIME ZONE 'UTC' - INTERVAL '6 days') AND now()",
          v.last_active_at
        )
  end

  @spec week_before_last(queryable()) :: query()
  def week_before_last(queryable \\ __MODULE__) do
    from v in queryable,
      where:
        fragment(
          "? BETWEEN (now() AT TIME ZONE 'UTC' - INTERVAL '13 days') AND (now() AT TIME ZONE 'UTC' - INTERVAL '6 days')",
          v.last_active_at
        )
  end

  @spec unique(queryable()) :: query()
  def unique(queryable \\ __MODULE__) do
    from v in queryable, distinct: v.visitor_id
  end

  @spec duration(queryable()) :: query()
  def duration(queryable \\ __MODULE__) do
    from v in queryable,
      select:
        fragment("COALESCE(AVG(? - ?), INTERVAL '0 seconds')", v.last_active_at, v.started_at)
  end

  @spec per_day_query() :: String.t()
  def per_day_query do
    """
      SELECT dates.date, COUNT(DISTINCT visitor_id)
      FROM analytics_visits
      RIGHT JOIN (
        SELECT DATE(GENERATE_SERIES((NOW() - INTERVAL '6 days'), NOW(), INTERVAL '1 day')) AS date
      ) dates ON DATE(started_at) = dates.date
      GROUP BY dates.date
      ORDER BY dates.date
    """
  end
end
