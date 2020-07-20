defmodule PratiBa.Stats.Visitor do
  use Ecto.Schema
  import Ecto.Changeset

  alias PratiBa.Stats.Request

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "visitors" do
    has_many :requests, Request

    timestamps()
  end

  @doc false
  def changeset(visitor, attrs) do
    visitor
    |> cast(attrs, [:id])
    |> validate_required([:id])
    |> unique_constraint(:id)
  end
end
