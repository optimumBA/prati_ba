defmodule PratiBa.Articles do
  @moduledoc """
  The Articles context.
  """

  alias PratiBa.Articles.{Article, Category, Source}
  alias PratiBa.Repo

  @doc """
  Returns the list of articles grouped by categories.

  ## Examples

      iex> list_categories_with_articles()
      [%Category{articles: [%Article{}, ...]}, ...]

  """
  def list_categories_with_articles do
    Article.newest()
    |> Category.with_articles()
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
    |> Repo.preload(:category)
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
    category = Repo.get_by!(Category, name: attrs.category)

    %Article{}
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:category, category)
    |> Ecto.Changeset.put_assoc(:source, source)
    |> Repo.insert()
  end

  @doc """
  Returns the list of sources.

  ## Examples

      iex> list_sources()
      [%Source{}, ...]

  """
  def list_sources, do: Repo.all(Source)
end
