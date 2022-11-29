defmodule PratiBaWeb.Components.ArticleComponent do
  use PratiBaWeb, :component

  alias PratiBa.Articles.Article
  alias PratiBa.Uploaders.ArticleImage

  def article(assigns) do
    ~H"""
    <article class="column" id={"article-" <> @article.id}>
      <%= link to: Routes.article_path(@socket, :show, @article), class: "article", target: "_blank", rel: "noopener" do %>
        <.article_image article={@article} />
        <.article_details article={@article} />
      <% end %>
    </article>
    """
  end

  defp article_image(%{article: %Article{image: nil}} = assigns) do
    ~H"""
    <div class="article-image"></div>
    """
  end

  defp article_image(assigns) do
    ~H"""
    <div class="article-image">
      <%= img_tag(ArticleImage.url({@article.image, @article})) %>
    </div>
    """
  end

  defp article_details(%{} = assigns) do
    ~H"""
    <div class="article-details">
      <div class="article-title"><%= @article.title %></div>

      <div class="article-info">
        <span class="article-source"><%= @article.source.name %></span>
        | <.published_date article={@article} />
      </div>
    </div>
    """
  end

  defp published_date(%{article: %Article{published_at: published_at}} = assigns) do
    datetime = DateTime.from_naive!(published_at, "Etc/UTC")

    relative_string =
      case Timex.format(datetime, "{relative}", :relative) do
        {:ok, relative_string} ->
          relative_string

        {:error, _} ->
          nil
      end

    assigns = assign(assigns, relative_string: relative_string, datetime: datetime)

    ~H"""
    <time class="article-published" datetime={@datetime}><%= @relative_string %></time>
    """
  end
end
