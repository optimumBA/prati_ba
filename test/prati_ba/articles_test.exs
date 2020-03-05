defmodule PratiBa.ArticlesTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles

  describe "articles" do
    alias PratiBa.Articles.Article

    @valid_attrs %{published_at: ~N[2020-03-04 19:09:00], title: "Article Title", url: "https://google.com"}
    @update_attrs %{published_at: ~N[2020-03-04 19:09:00], title: "New Article Title", url: "https://google.com"}
    @invalid_attrs %{published_at: nil, title: nil, url: nil}

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Articles.create_article()

      article
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert Articles.list_articles() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Articles.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = Articles.create_article(@valid_attrs)
      assert article.published_at == ~N[2020-03-04 19:09:00]
      assert article.title == "Article Title"
      assert article.url == "https://google.com"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, %Article{} = article} = Articles.update_article(article, @update_attrs)
      assert article.published_at == ~N[2020-03-04 19:09:00]
      assert article.title == "New Article Title"
      assert article.url == "https://google.com"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Articles.update_article(article, @invalid_attrs)
      assert article == Articles.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Articles.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Articles.change_article(article)
    end
  end
end
