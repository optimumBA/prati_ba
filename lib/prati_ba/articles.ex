defmodule PratiBa.Articles do
  @moduledoc """
  The Articles context.
  """

  alias PratiBa.Articles.{Article, Source}
  alias PratiBa.Repo

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Article
    |> Repo.all()
    |> Repo.preload(:source)
  end

  @doc """
  Checks if the article already exists.

  ## Examples

      iex> exists?(%{url: existing})
      true

      iex> exists?(%{url: new})
      false

  """
  def exists?(%{url: url}) do
    url
    |> Article.having_url()
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
    %Article{}
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:source, source)
    |> Repo.insert()
  end

  @doc """
  Gets a single source.

  Raises `Ecto.NoResultsError` if the Source does not exist.

  ## Examples

      iex> get_source!("Existing source")
      %Source{}

      iex> get_source!("Non-existent source")
      ** (Ecto.NoResultsError)

  """
  def get_source!(name), do: Repo.get_by!(Source, name: name)
end
