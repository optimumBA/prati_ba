defmodule PratiBaWeb.ArticleLive.Index do
  use PratiBaWeb, :live_view

  alias Phoenix.LiveView.Socket
  alias PratiBa.Articles
  alias PratiBaWeb.ArticleView

  @impl true
  def mount(_params, _session, socket) do
    Articles.subscribe()
    {:ok, fetch(socket)}
  end

  @impl true
  def render(%{group: true} = assigns), do: ArticleView.render("grouped.html", assigns)
  def render(assigns), do: ArticleView.render("index.html", assigns)

  @impl true
  def handle_info({Articles, [:article | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      case params["group"] do
        "true" -> assign(socket, group: true)
        _ -> assign(socket, group: false)
      end

    {:noreply, fetch(socket)}
  end

  defp fetch(%Socket{assigns: %{group: true}} = socket) do
    assign(socket, categories: Articles.list_categories_with_articles())
  end
  defp fetch(socket) do
    assign(socket, articles: Articles.list_articles())
  end
end
