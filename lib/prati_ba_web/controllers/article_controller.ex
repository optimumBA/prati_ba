defmodule PratiBaWeb.ArticleController do
  use PratiBaWeb, :controller

  alias PratiBa.Articles

  def show(conn, %{"id" => id}) do
    article = Articles.get_article!(id)
    redirect(conn, external: article.url)
  end
end
