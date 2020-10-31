defmodule PratiBaWeb.ArticleView do
  use PratiBaWeb, :view

  import Phoenix.HTML.Tag

  alias PratiBa.Articles.Article
  alias PratiBa.Uploaders.ArticleImage

  def article_image_tag(%Article{image: nil}), do: nil

  def article_image_tag(%Article{image: image} = article) do
    original_image =
      {image, article}
      |> ArticleImage.url(:original)

    square_image =
      {image, article}
      |> ArticleImage.url(:square)


    content_tag(:picture) do
      [
        tag(:source, srcset: square_image, media: "(max-width: 600px)"),
        img_tag(original_image)
      ]
    end
  end

  def published_date(%Article{published_at: published_at}) do
    datetime = DateTime.from_naive!(published_at, "Etc/UTC")

    content_tag(:time, class: "article-published", datetime: datetime) do
      case Timex.format(datetime, "{relative}", :relative) do
        {:ok, relative_string} ->
          relative_string

        {:error, _} ->
          nil
      end
    end
  end
end
