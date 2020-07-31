defmodule PratiBa.ArticlesTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Articles

  describe "articles" do
    alias PratiBa.Articles.{Article, Source}

    @valid_attrs %{
      image: "https://via.placeholder.com/350x150",
      original_id: "1234",
      published_at: ~N[2020-03-11 07:50:00],
      title: "Article Title",
      url: "https://sourcedomain.com/valid"
    }
    @invalid_attrs %{image: nil, original_id: nil, published_at: nil, title: nil, url: nil}

    test "list_articles/0 returns newest articles" do
      article = insert(:article)
      article_id = article.id
      assert [%Article{id: ^article_id}] = Articles.list_articles()
    end

    test "get_article!/1 returns the article with given ID" do
      article = insert(:article)
      assert Articles.get_article!(article.id) == article
    end

    test "exists?/1 returns true when article with the same original ID from the same source is already in the DB" do
      source = insert(:source)
      insert(:article, original_id: "26132", source: source)

      attrs =
        %{original_id: "26132"}
        |> Enum.into(@valid_attrs)

      assert Articles.exists?(source.id, attrs) == true
    end

    test "exists?/1 returns false when there is no article with the same original ID from the same source in the DB" do
      insert(:article, original_id: "84256")

      source = insert(:source)

      attrs =
        %{original_id: "84256"}
        |> Enum.into(@valid_attrs)

      assert Articles.exists?(source.id, attrs) == false
    end

    test "exists?/1 returns false when there is an article with the same original ID but different source in the DB" do
      insert(:article, original_id: "768")

      source = insert(:source)

      attrs =
        %{original_id: "768"}
        |> Enum.into(@valid_attrs)

      assert Articles.exists?(source.id, attrs) == false
    end

    test "create_article/2 with valid data creates an article" do
      source = insert(:source, name: "Great source")
      assert {:ok, %Article{} = article} = Articles.create_article(source, @valid_attrs)
      refute is_nil(article.image)
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
