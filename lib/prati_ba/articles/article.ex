defmodule PratiBa.Articles.Article do
  use PratiBa.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Articles.{Category, Source}
  alias PratiBa.Uploaders.ArticleImage

  schema "articles" do
    field :image, ArticleImage.Type
    field :published_at, :naive_datetime
    field :title, :string
    field :url, EctoFields.URL
    belongs_to :category, Category
    belongs_to :source, Source

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:published_at, :title, :url])
    |> cast_attachments(attrs, [:image], allow_urls: true)
    |> validate_required([:published_at, :title, :url])
    |> unique_constraint(:url)
  end

  def having_url(url) do
    from a in __MODULE__, where: a.url == ^url
  end

  def newest(limit \\ 9) do
    articles = from a in __MODULE__,
      select: %{id: a.id, rank: over(rank(), :category)},
      windows: [category: [partition_by: a.category_id, order_by: [desc_nulls_last: :published_at]]]

    from a in __MODULE__,
      join: grouped in subquery(articles), on: [id: a.id],
      where: grouped.rank <= ^limit,
      preload: :source
  end
end
