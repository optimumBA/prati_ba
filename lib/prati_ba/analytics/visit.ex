defmodule PratiBa.Analytics.Visit do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Analytics.Visitor

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
    field :raw, :map
    field :size, :string
    field :started_at, :naive_datetime
    belongs_to :visitor, Visitor

    timestamps()
  end

  @doc false
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

  def active(queryable \\ __MODULE__) do
    from v in queryable,
      where: fragment("? > now() AT TIME ZONE 'UTC' - INTERVAL '10 minutes'", v.last_active_at)
  end
end
