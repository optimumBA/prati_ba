defmodule PratiBa.Analytics.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "visits" do
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
    field :visitor_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:location, :isp, :os, :device, :browser, :size, :language, :raw, :started_at, :last_active_at])
    |> validate_required([:location, :isp, :os, :device, :browser, :size, :language, :raw, :started_at, :last_active_at])
  end
end
