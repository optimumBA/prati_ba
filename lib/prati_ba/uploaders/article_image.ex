defmodule PratiBa.Uploaders.ArticleImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :square]

  def filename(:square, {_file, article}) do
    "#{article.id}_square"
  end

  def filename(_version, {_file, article}) do
    article.id
  end

  def storage_dir(_version, {_file, _scope}), do: "uploads/articles"

  def transform(:original, _) do
    {:convert, "-format jpg", :jpg}
  end

  def transform(:square, _) do
    {:magick, "-gravity center -extent %[fx:h<w?h:w]x%[fx:h<w?h:w] -format jpg", :jpg}
  end

  def s3_object_headers(_version, {_file, _scope}) do
    [content_type: "image/jpeg"]
  end
end
