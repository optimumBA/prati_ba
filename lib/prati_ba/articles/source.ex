defmodule PratiBa.Articles.Source do
  use PratiBa.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Articles.Article

  schema "sources" do
    field :enabled, :boolean, default: true
    field :name, :string
    field :url, EctoFields.URL
    has_many :articles, Article

    timestamps()
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> unique_constraint(:name)
  end

  def enabled(queryable \\ __MODULE__) do
    from s in queryable, where: s.enabled == true
  end
end
