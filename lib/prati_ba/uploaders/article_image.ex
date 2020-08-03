defmodule PratiBa.Uploaders.ArticleImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:thumb]

  def filename(_version, {_file, article}) do
    article.id
  end

  def storage_dir(_version, {_file, _scope}), do: "uploads/articles"

  def transform(:thumb, _) do
    {:convert, "-format jpg", :jpg}
  end

  def s3_object_headers(_version, {_file, _scope}) do
    [content_type: "image/jpeg"]
  end
end
