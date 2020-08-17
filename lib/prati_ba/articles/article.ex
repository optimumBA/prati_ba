defmodule PratiBa.Articles.Article do
  use PratiBa.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Articles.Source
  alias PratiBa.Uploaders.ArticleImage

  schema "articles" do
    field :image, ArticleImage.Type
    field :original_id, :string
    field :published_at, :naive_datetime
    field :title, :string
    field :url, EctoFields.URL
    belongs_to :source, Source

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:original_id, :published_at, :title, :url])
    |> validate_required([:original_id, :published_at, :title, :url])
    |> unique_constraint([:original_id, :source_id])
  end

  def image_changeset(article, attrs) do
    article
    |> cast_attachments(attrs, [:image], allow_urls: true)
    |> validate_required([:image])
  end

  def having_original_id(source_id, original_id) do
    from a in __MODULE__, where: a.source_id == ^source_id and a.original_id == ^original_id
  end

  def newest(limit \\ 15) do
    from a in __MODULE__,
      order_by: [desc_nulls_last: :published_at, desc_nulls_last: :inserted_at],
      limit: ^limit,
      preload: :source
  end
end
