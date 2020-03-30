defmodule PratiBa.Uploaders.ArticleImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:thumb]

  def filename(_version, {file, _article}) do
    file_name = :sha
    |> :crypto.hash(file.file_name)
    |> Base.encode16
    |> String.downcase

    extension = Path.extname(file.file_name)

    "#{file_name}#{extension}"
  end

  def storage_dir(_version, {_file, _scope}), do: "uploads/articles"

  def transform(:thumb, _) do
    {:convert, "-thumbnail 200x200^ -gravity center -extent 200x200 -format jpg", :jpg}
  end
end
