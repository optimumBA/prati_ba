defmodule PratiBa.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:analytics_visits, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :location, :map
      add :isp, :string
      add :os, :map
      add :device, :map
      add :browser, :map
      add :size, :string
      add :language, :string
      add :raw, :map, null: false, default: "{}"
      add :started_at, :naive_datetime
      add :last_active_at, :naive_datetime

      add :visitor_id, references(:analytics_visitors, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:analytics_visits, [:visitor_id])
  end
end
