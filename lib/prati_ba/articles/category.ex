defmodule PratiBa.Articles.Category do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Articles.Article

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "categories" do
    field :name, :string
    field :order, :integer, default: 0
    has_many :articles, Article

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :order])
    |> validate_required([:name, :order])
    |> unique_constraint(:name)
  end

  def with_articles(articles_query \\ Article) do
    from c in __MODULE__,
      preload: [articles: ^articles_query],
      order_by: [asc: :order]
  end
end
