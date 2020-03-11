defmodule PratiBa.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :url, :string, null: false
      add :title, :string, null: false
      add :image, :string
      add :published_at, :naive_datetime, null: false
      add :source_id, references(:sources, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:articles, [:url])
    create index(:articles, [:source_id])
  end
end
