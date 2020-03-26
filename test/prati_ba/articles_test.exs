defmodule PratiBa.ArticlesTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles

  describe "articles" do
    alias PratiBa.Articles.{Article, Source}

    @valid_attrs %{image: nil, published_at: ~N[2020-03-11 07:50:00], title: "Article Title", url: "https://sourcedomain.com/valid"}
    @invalid_attrs %{image: nil, published_at: nil, title: nil, url: nil}

    test "list_articles/0 returns all articles" do
      article = insert(:article)
      assert Articles.list_articles() == [article]
    end

    test "exists?/1 returns true when article with the same URL is already in the DB" do
      url = "https://sourcedomain.com/articles/new-article"
      insert(:article, url: url)

      attrs =
        %{url: url}
        |> Enum.into(@valid_attrs)

      assert Articles.exists?(attrs) == true
    end

    test "exists?/1 returns false when there is no article with the same URL in the DB" do
      url = "https://sourcedomain.com/articles/new-article"
      insert(:article, url: "https://differentdomain.com/article")

      attrs =
        %{url: url}
        |> Enum.into(@valid_attrs)

      assert Articles.exists?(attrs) == false
    end

    test "create_article/2 with valid data creates a article" do
      source = insert(:source, name: "Great source")
      assert {:ok, %Article{} = article} = Articles.create_article(source, @valid_attrs)
      assert article.image == nil
      assert article.published_at == ~N[2020-03-11 07:50:00]
      assert article.title == "Article Title"
      assert article.url == "https://sourcedomain.com/valid"
      assert %Source{name: "Great source"} = article.source
    end

    test "create_article/2 with invalid data returns error changeset" do
      source = insert(:source)
      assert {:error, %Ecto.Changeset{}} = Articles.create_article(source, @invalid_attrs)
    end
  end

  describe "sources" do
    test "list_sources/0 returns all sources" do
      source = insert(:source)
      assert Articles.list_sources() == [source]
    end
  end
end
