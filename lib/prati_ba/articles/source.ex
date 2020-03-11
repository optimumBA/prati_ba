defmodule PratiBa.Articles.Source do
  use PratiBa.Schema
  import Ecto.Changeset

  alias PratiBa.Articles.Article

  schema "sources" do
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
end
