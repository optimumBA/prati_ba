defmodule PratiBa.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :url, :string, null: false

      timestamps()
    end

    create unique_index(:sources, [:name])
  end
end
