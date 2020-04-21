defmodule PratiBaWeb.ArticleController do
  use PratiBaWeb, :controller

  alias PratiBa.Articles

  def index(conn, _params) do
    categories = Articles.list_categories_with_articles()
    render(conn, "index.html", categories: categories)
  end

  def show(conn, %{"id" => id}) do
    article = Articles.get_article!(id)
    redirect(conn, external: article.url)
  end
end
