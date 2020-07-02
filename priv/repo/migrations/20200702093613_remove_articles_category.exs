defmodule PratiBa.Repo.Migrations.RemoveArticlesCategory do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      remove :category_id, references(:categories, on_delete: :nilify_all, type: :binary_id), null: true
    end
  end
end
