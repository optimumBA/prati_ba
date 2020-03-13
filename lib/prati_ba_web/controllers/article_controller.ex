defmodule PratiBaWeb.ArticleController do
  use PratiBaWeb, :controller

  alias PratiBa.Articles

  def index(conn, _params) do
    articles = Articles.list_articles()
    render(conn, "index.html", articles: articles)
  end
end
