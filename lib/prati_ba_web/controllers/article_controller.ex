defmodule PratiBaWeb.ArticleController do
  @moduledoc false
  use PratiBaWeb, :controller

  alias PratiBa.Analytics
  alias PratiBa.Analytics.EventType
  alias PratiBa.Analytics.Visit
  alias PratiBa.Articles
  alias PratiBa.Articles.Article

  @type conn :: Plug.Conn.t()

  @spec show(conn(), map()) :: conn()
  def show(conn, %{"id" => id}) do
    article = Articles.get_article!(id)
    track_article_view(conn, article)
    redirect(conn, external: article.url)
  end

  defp track_article_view(conn, %Article{id: article_id}) do
    with %Visit{} = visit <- conn.assigns[:visit],
         %EventType{} = event_type <- Analytics.get_event_type("article_view") do
      Analytics.create_event(visit, event_type, %{
        details: %{id: article_id},
        requested_at: NaiveDateTime.utc_now()
      })
    end
  end
end
