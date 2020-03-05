defmodule PratiBa.ArticleTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles.Article

  test "url must have valid format" do
    changeset = Article.changeset(%Article{}, %{url: "invalid_url"})
    assert %{url: ["is invalid"]} = errors_on(changeset)
  end
end
