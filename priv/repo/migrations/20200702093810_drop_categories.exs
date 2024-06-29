defmodule PratiBa.Repo.Migrations.DropCategories do
  use Ecto.Migration

  def up do
    drop table(:categories)
  end

  def down do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :order, :integer, null: false, default: 0

      timestamps()
    end

    create unique_index(:categories, [:name])
  end
end
