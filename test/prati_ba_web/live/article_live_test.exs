defmodule PratiBaWeb.ArticleLiveTest do
  use PratiBaWeb.ConnCase

  import Phoenix.LiveViewTest

  alias PratiBa.Articles

  defp create_article(_) do
    first_article =
      insert(:article, title: "First article", published_at: ~N[2020-04-23 19:12:00])

    second_article =
      insert(:article, title: "Second article", published_at: ~N[2020-04-23 19:20:00])

    %{
      first_article: first_article,
      second_article: second_article
    }
  end

  defp create_source(_) do
    %{source: insert(:source)}
  end

  defp create_loading_articles do
    for i <- 1..20 do
      insert(:article, title: "Article#{i}", published_at: ~N[2020-04-23 19:12:00])
    end
  end

  defp number_of_articles(html) do
    html |> :binary.matches("Article") |> length()
  end

  describe "Index" do
    setup [:create_article, :create_source]

    test "lists all articles", %{
      conn: conn,
      first_article: first_article,
      second_article: second_article
    } do
      {:ok, index_live, _html} = live(conn, ~p"/")

      {:ok, current_date} = Timex.format(NaiveDateTime.utc_now(), "%A, %d.%m.%Y", :strftime)

      assert has_element?(index_live, "#current_date", current_date)
      assert has_element?(index_live, "#article-#{first_article.id}", "First article")
      assert has_element?(index_live, "#article-#{second_article.id}", "Second article")
    end

    test "gets updated with new articles", %{conn: conn, source: source} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      attrs = build(:article, image: "https://placekitten.com/350/150") |> Map.from_struct()
      {:ok, article} = Articles.create_article(source, attrs)

      {:ok, index_live, _html} = live(conn, ~p"/")

      assert has_element?(index_live, "#article-#{article.id}", article.title)
    end

    test "renders more articles when user scrolls to bottom", %{conn: conn} do
      create_loading_articles()

      {:ok, view, _html} = live(conn, ~p"/")

      assert render(view) |> number_of_articles() == 14

      view
      |> element("#footer")
      |> render_hook("load_more", %{})

      assert render(view) |> number_of_articles() == 20
    end
  end
end
