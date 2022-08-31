defmodule PratiBaWeb.ArticleLive.Index do
  use PratiBaWeb, :live_view

  alias PratiBa.Articles
  alias PratiBaWeb.Components.ArticleComponent

  @impl true
  def mount(_params, _session, socket) do
    Articles.subscribe()
    {:ok, fetch(socket)}
  end

  @impl true
  def handle_info({Articles, [:article | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, articles: Articles.list_articles())
  end
end
