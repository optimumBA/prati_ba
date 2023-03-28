defmodule PratiBa.Uploaders.ArticleImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @acl :public_read
  @versions [:thumb]

  def filename(_version, {_file, article}) do
    article.id
  end

  def storage_dir(_version, {_file, _scope}), do: "articles"

  def transform(:thumb, _) do
    {:convert, "-thumbnail 500x500^ -gravity center -extent 500x500 -format jpg", :jpg}
  end

  def s3_object_headers(_version, {_file, _scope}) do
    [content_type: "image/jpeg"]
  end
end
