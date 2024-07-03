defmodule PratiBa.Analytics.EventType do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias PratiBa.Analytics.Event

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analytics_event_types" do
    field :name, :string
    has_many :events, Event

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(event_type, attrs) do
    event_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
