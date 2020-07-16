defmodule PratiBa.Analytics.Request do
  use Ecto.Schema
  import Ecto.Changeset

  alias PratiBa.Analytics.Visitor

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "requests" do
    field :geo, :map
    field :isp, :string
    field :path, :string
    field :raw, :map
    field :referer, :string
    field :user_agent, :map
    belongs_to :visitor, Visitor

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:id, :path, :referer, :isp, :geo, :user_agent, :raw])
    |> validate_required([:id, :path, :raw])
    |> unique_constraint(:id)
  end
end
