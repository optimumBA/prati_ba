defmodule PratiBaWeb.ArticleLive.Index do
  use PratiBaWeb, :live_view

  alias PratiBa.Articles
  alias PratiBaWeb.Components.ArticleComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page: 1, limit: 15)
      |> load_articles()

    {:ok, socket, temporary_assigns: [articles: []]}
  end

  defp load_articles(socket) do
    assign(socket,
      articles:
        Articles.list_articles(
          page: socket.assigns.page,
          limit: socket.assigns.limit
        )
    )
  end

  @impl true
  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))
      |> load_articles()

    {:noreply, socket}
  end

  @impl true
  def handle_info({Articles, [:article | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    assign(socket, articles: Articles.list_articles(page: 1, limit: 15))
  end
end
