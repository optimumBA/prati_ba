defmodule PratiBa.Repo.Migrations.MakeArticlesCategoryNullable do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      modify :category_id, references(:categories, on_delete: :nilify_all, type: :binary_id),
        null: true,
        from: references(:categories, on_delete: :delete_all, type: :binary_id)
    end
  end
end
