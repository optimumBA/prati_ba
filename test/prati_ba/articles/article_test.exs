defmodule PratiBa.Articles.ArticleTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles.Article

  @valid_attrs %{image: nil, published_at: ~N[2020-03-11 07:50:00], title: "Article Title", url: "https://sourcedomain.com/valid"}

  test "url must have valid format" do
    changeset = Article.changeset(%Article{}, %{url: "invalid_url"})
    assert %{url: ["is invalid"]} = errors_on(changeset)
  end

  test "cannot create duplicate article" do
    article = Article.changeset(%Article{}, @valid_attrs)
    assert {:ok, article } = Repo.insert(article)

    duplicate = Article.changeset(%Article{}, @valid_attrs)

    assert {:error, changeset} = Repo.insert(duplicate)
    assert %{url: ["has already been taken"]} = errors_on(changeset)
  end
end
