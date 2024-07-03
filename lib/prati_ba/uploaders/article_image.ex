defmodule PratiBa.Uploaders.ArticleImage do
  @moduledoc false

  use Waffle.Definition
  use Waffle.Ecto.Definition

  @acl :public_read
  @versions [:thumb]

  @spec filename(any, any) :: Ecto.UUID.t()
  def filename(_version, {_file, article}) do
    article.id
  end

  @spec storage_dir(any, any) :: String.t()
  def storage_dir(_version, {_file, _scope}), do: "articles"

  @spec transform(:thumb, any) :: {:convert, String.t(), atom}
  def transform(:thumb, _any) do
    {:convert, "-thumbnail 500x500^ -gravity center -extent 500x500 -format jpg", :jpg}
  end

  @spec s3_object_headers(any, any) :: [any]
  def s3_object_headers(_version, {_file, _scope}) do
    [content_type: "image/jpeg"]
  end
end
