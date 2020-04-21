defmodule PratiBa.ArticlesTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles

  describe "articles" do
    alias PratiBa.Articles.{Article, Category, Source}

    @valid_attrs %{category: "Category", image: nil, published_at: ~N[2020-03-11 07:50:00], title: "Article Title", url: "https://sourcedomain.com/valid"}
    @invalid_attrs %{category: "Category", image: nil, published_at: nil, title: nil, url: nil}

    test "list_categories_with_articles/0 returns all categories with articles preloaded" do
      article = insert(:article)
      assert [category] = Articles.list_categories_with_articles()
      assert category.name == article.category.name
      assert length(category.articles) == 1
      article_id = article.id
      assert %Article{id: ^article_id} = Enum.at(category.articles, 0)
    end

    test "get_article!/1 returns the article with given ID" do
      article = insert(:article)
      assert Articles.get_article!(article.id) == article
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

    test "create_article/2 with valid data creates an article" do
      insert(:category, name: "Category")
      source = insert(:source, name: "Great source")
      assert {:ok, %Article{} = article} = Articles.create_article(source, @valid_attrs)
      assert article.image == nil
      assert article.published_at == ~N[2020-03-11 07:50:00]
      assert article.title == "Article Title"
      assert article.url == "https://sourcedomain.com/valid"
      assert %Category{name: "Category"} = article.category
      assert %Source{name: "Great source"} = article.source
    end

    test "create_article/2 with invalid data returns error changeset" do
      insert(:category, name: "Category")
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
