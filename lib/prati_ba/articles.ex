defmodule PratiBa.Articles do
  @moduledoc """
  The Articles context.
  """

  alias PratiBa.Articles.Article
  alias PratiBa.Articles.Source
  alias PratiBa.Repo

  @topic inspect(__MODULE__)

  @doc """
  Subscribes to article events.

  ## Examples

    iex> subscribe
    :ok
  """
  @spec subscribe() :: :ok
  def subscribe do
    Phoenix.PubSub.subscribe(PratiBa.PubSub, @topic)
  end

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  @spec list_articles(Keyword.t()) :: [Article.t()]
  def list_articles(opts \\ []) do
    limit = Keyword.get(opts, :limit, 15)
    page = Keyword.get(opts, :page, 1)

    Article
    |> Article.from_enabled_sources()
    |> Article.newest(limit, page)
    |> Repo.all()
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!("binary-id")
      %Source{}

      iex> get_article!("non-existent-article-id")
      ** (Ecto.NoResultsError)

  """
  @spec get_article!(Ecto.UUID.t()) :: Article.t()
  def get_article!(id) do
    Article
    |> Repo.get!(id)
    |> Repo.preload(:source)
  end

  @doc """
  Checks if the article already exists.

  ## Examples

      iex> exists?(1, %{original_id: existing})
      true

      iex> exists?(1, %{original_id: new})
      false

  """
  @spec exists?(Ecto.UUID.t(), map()) :: boolean()
  def exists?(source_id, %{original_id: original_id}) do
    source_id
    |> Article.having_original_id(original_id)
    |> Repo.exists?()
  end

  @doc """
  Creates an article.

  ## Examples

      iex> create_article(%Source{}, %{field: value})
      {:ok, %Article{}}

      iex> create_article(%Source{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_article(Source.t(), map) :: {:ok, Article.t()} | {:error, Ecto.Changeset.t()}
  def create_article(%Source{} = source, attrs \\ %{}) do
    article_changeset =
      %Article{}
      |> Article.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:source, source)

    transaction =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:article, article_changeset)
      |> Ecto.Multi.update(:article_with_image, &Article.image_changeset(&1.article, attrs))
      |> Repo.transaction()

    case transaction do
      {:ok, result} ->
        Phoenix.PubSub.broadcast(PratiBa.PubSub, @topic, {
          __MODULE__,
          [:article, :created],
          result.article_with_image
        })

        {:ok, result.article_with_image}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns the list of sources.

  ## Examples

      iex> list_sources()
      [%Source{}, ...]

  """
  @spec list_sources() :: [Source.t()]
  def list_sources do
    Source
    |> Source.enabled()
    |> Repo.all()
  end
end
