defmodule PratiBaWeb.ArticleController do
  use PratiBaWeb, :controller

  alias PratiBa.Analytics
  alias PratiBa.Articles
  alias PratiBa.Articles.Article

  def show(conn, %{"id" => id}) do
    article = Articles.get_article!(id)
    track_article_view(conn, article)
    redirect(conn, external: article.url)
  end

  defp track_article_view(conn, %Article{id: article_id}) do
    with visit <- conn.assigns[:visit],
         event_type <- Analytics.get_event_type("article_view") do
      Analytics.create_event(visit, event_type, %{
        details: %{id: article_id},
        requested_at: NaiveDateTime.utc_now()
      })
    end
  end
end
