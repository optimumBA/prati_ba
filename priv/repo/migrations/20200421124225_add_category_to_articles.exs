defmodule PratiBa.Repo.Migrations.AddCategoryToArticles do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id), null: false
    end

    create index(:articles, [:category_id])
  end
end
