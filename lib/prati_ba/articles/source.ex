defmodule PratiBa.Articles.Source do
  @moduledoc false

  use PratiBa.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Articles.Article

  @type t :: %__MODULE__{}

  schema "sources" do
    field :enabled, :boolean, default: true
    field :name, :string
    field :url, EctoFields.URL
    has_many :articles, Article

    timestamps()
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> unique_constraint(:name)
  end

  @spec enabled(Ecto.Queryable.t()) :: Ecto.Query.t()
  def enabled(queryable \\ __MODULE__) do
    from s in queryable, where: s.enabled == true
  end
end
