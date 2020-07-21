defmodule PratiBa.Repo.Migrations.CreateAnalyticsEvents do
  use Ecto.Migration

  def change do
    create table(:analytics_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :details, :map
      add :requested_at, :naive_datetime
      add :started_at, :naive_datetime
      add :finished_at, :naive_datetime

      add :event_type_id,
          references(:analytics_event_types, on_delete: :delete_all, type: :binary_id),
          null: false

      add :visit_id, references(:analytics_visits, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:analytics_events, [:event_type_id])
    create index(:analytics_events, [:visit_id])
  end
end
