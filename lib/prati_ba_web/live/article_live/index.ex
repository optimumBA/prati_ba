defmodule PratiBaWeb.ArticleLive.Index do
  use PratiBaWeb, :live_view

  alias PratiBa.Articles
  alias PratiBaWeb.Components.ArticleComponent

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Articles.subscribe()

    socket =
      socket
      |> assign(:page, 1)
      |> assign(:limit, 15)
      |> assign(:new_articles, false)
      |> stream(
        :articles,
        Articles.list_articles(page: 1, limit: 15)
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("refresh_articles", _params, socket) do
    socket =
      socket
      |> assign(:new_articles, false)
      |> prepend_more_articles()

    {:noreply, socket}
  end

  def handle_event("load_more", _params, socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))
      |> load_articles()

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({Articles, [:article | _status], _article}, socket) do
    {:noreply, assign(socket, :new_articles, true)}
  end

  defp load_articles(socket) do
    stream_insert_many(
      socket,
      :articles,
      Articles.list_articles(
        page: socket.assigns.page,
        limit: socket.assigns.limit
      )
    )
  end

  defp prepend_more_articles(socket) do
    articles_list =
      Articles.list_articles(
        page: 1,
        limit: socket.assigns.limit
      )

    stream_insert_many(
      socket,
      :articles,
      Enum.reverse(articles_list),
      at: 0
    )
  end
end
