defmodule PratiBa.Articles.SourceTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles.Source

  @valid_attrs %{name: "Source", url: "https://google.com"}

  test "url must have valid format" do
    changeset = Source.changeset(%Source{}, %{url: "invalid_url"})
    assert %{url: ["is invalid"]} = errors_on(changeset)
  end

  test "cannot create duplicate source" do
    source = Source.changeset(%Source{}, @valid_attrs)
    assert {:ok, _source} = Repo.insert(source)

    duplicate = Source.changeset(%Source{}, @valid_attrs)

    assert {:error, changeset} = Repo.insert(duplicate)
    assert %{name: ["has already been taken"]} = errors_on(changeset)
  end
end
