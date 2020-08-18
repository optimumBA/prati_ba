defmodule PratiBa.Articles do
  @moduledoc """
  The Articles context.
  """

  alias PratiBa.Articles.{Article, Source}
  alias PratiBa.Repo

  @topic inspect(__MODULE__)

  @doc """
  Subscribes to article events.

  ## Examples

    iex> subscribe
    :ok
  """
  def subscribe do
    Phoenix.PubSub.subscribe(PratiBa.PubSub, @topic)
  end

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Article
    |> Article.from_enabled_sources()
    |> Article.newest()
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
  def exists?(source_id, %{original_id: original_id}) do
    Article.having_original_id(source_id, original_id)
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

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns the list of sources.

  ## Examples

      iex> list_sources()
      [%Source{}, ...]

  """
  def list_sources do
    Source
    |> Source.enabled()
    |> Repo.all()
  end
end
