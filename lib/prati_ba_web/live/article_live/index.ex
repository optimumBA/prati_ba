defmodule PratiBaWeb.ArticleLive.Index do
  use PratiBaWeb, :live_view

  alias PratiBa.Articles
  alias PratiBaWeb.Components.ArticleComponent

  @impl true
  def mount(_params, _session, socket) do
    Articles.subscribe()

    socket =
      socket
      |> assign(:page, 1)
      |> assign(:limit, 15)
      |> assign(:new_articles, false)
      |> assign(:update, "append")
      |> load_articles()

    {:ok, socket, temporary_assigns: [articles: []]}
  end

  @impl true
  def handle_event("refresh_articles", _params, socket) do
    socket =
      socket
      |> assign(:page, 1)
      |> assign(:new_articles, false)
      |> load_articles()

    {:noreply, socket}
  end

  def handle_event("load_more", _params, socket) do
    socket =
      socket
      |> assign(:update, "append")
      |> update(:page, &(&1 + 1))
      |> load_articles()

    {:noreply, socket}
  end

  @impl true
  def handle_info({Articles, [:article | _status], _article}, socket) do
    socket =
      socket
      |> assign(:new_articles, true)
      |> assign(:update, "prepend")

    {:noreply, socket}
  end

  def load_articles(socket) do
    assign(
      socket,
      :articles,
      Articles.list_articles(
        page: socket.assigns.page,
        limit: socket.assigns.limit
      )
    )
  end
end
