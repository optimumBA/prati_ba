defmodule PratiBa.Repo.Migrations.AddOriginalIdToArticles do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      add :original_id, :string, null: false
    end

    create unique_index(:articles, [:original_id, :source_id])
    drop unique_index(:articles, [:url])
  end
end
