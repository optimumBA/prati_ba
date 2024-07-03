defmodule PratiBa.Articles.Article do
  @moduledoc false

  use PratiBa.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias PratiBa.Articles.Source
  alias PratiBa.Uploaders.ArticleImage

  @type changeset :: Ecto.Changeset.t()
  @type query :: Ecto.Query.t()
  @type queryable :: Ecto.Queryable.t()
  @type t :: %__MODULE__{}

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
  @spec changeset(t(), map) :: changeset()
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:original_id, :published_at, :title, :url])
    |> validate_required([:original_id, :title, :url])
    |> unique_constraint([:original_id, :source_id])
    |> maybe_remove_published_at()
  end

  defp maybe_remove_published_at(changeset) do
    published_at = get_field(changeset, :published_at)

    cond do
      is_nil(published_at) ->
        changeset

      NaiveDateTime.compare(NaiveDateTime.utc_now(), published_at) == :lt ->
        put_change(changeset, :published_at, nil)

      true ->
        changeset
    end
  end

  @spec image_changeset(t(), map) :: changeset()
  def image_changeset(article, attrs) do
    article
    |> cast_attachments(attrs, [:image], allow_urls: true)
    |> validate_required([:image])
  end

  @spec having_original_id(Ecto.UUID.t(), Ecto.UUID.t()) :: query()
  def having_original_id(source_id, original_id) do
    from a in __MODULE__, where: a.source_id == ^source_id and a.original_id == ^original_id
  end

  @spec newest(queryable(), integer(), integer()) :: query()
  def newest(queryable \\ __MODULE__, limit \\ 15, page \\ 1) do
    from a in queryable,
      order_by: [desc_nulls_last: :published_at, desc_nulls_last: :inserted_at],
      offset: ^((page - 1) * limit),
      limit: ^limit,
      preload: :source
  end

  @spec from_enabled_sources(queryable()) :: query()
  def from_enabled_sources(queryable \\ __MODULE__) do
    from a in queryable, join: s in Source, on: [id: a.source_id], where: s.enabled == true
  end
end
