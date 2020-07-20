defmodule PratiBa.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :details, :map
      add :requested_at, :naive_datetime
      add :started_at, :naive_datetime
      add :finished_at, :naive_datetime
      add :event_type, references(:event_types, on_delete: :delete_all, type: :binary_id), null: false
      add :visit, references(:visits, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:events, [:event_type])
    create index(:events, [:visit])
  end
end
