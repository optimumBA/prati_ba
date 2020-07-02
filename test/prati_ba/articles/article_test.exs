defmodule PratiBa.Articles.ArticleTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles.Article

  @valid_attrs %{image: nil, original_id: "1234", published_at: ~N[2020-03-11 07:50:00], title: "Article Title", url: "https://sourcedomain.com/valid"}

  test "url must have valid format" do
    changeset = Article.changeset(%Article{}, %{url: "invalid_url"})
    assert %{url: ["is invalid"]} = errors_on(changeset)
  end

  test "cannot create duplicate article" do
    source = insert(:source)

    article =
      %Article{}
      |> Article.changeset(@valid_attrs)
      |> Ecto.Changeset.put_assoc(:source, source)

    assert {:ok, article} = Repo.insert(article)

    duplicate =
      %Article{}
      |> Article.changeset(@valid_attrs)
      |> Ecto.Changeset.put_assoc(:source, source)

    assert {:error, changeset} = Repo.insert(duplicate)
    assert %{original_id: ["has already been taken"]} = errors_on(changeset)
  end
end
