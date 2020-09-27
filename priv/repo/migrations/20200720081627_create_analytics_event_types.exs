defmodule PratiBa.Repo.Migrations.CreateEventTypes do
  use Ecto.Migration

  def change do
    create table(:analytics_event_types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps()
    end

    create unique_index(:analytics_event_types, [:name])
  end
end
