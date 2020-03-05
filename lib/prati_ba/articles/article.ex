defmodule PratiBa.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "articles" do
    field :published_at, :naive_datetime
    field :title, :string
    field :url, EctoFields.URL

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :url, :published_at])
    |> validate_required([:title, :url, :published_at])
  end
end
