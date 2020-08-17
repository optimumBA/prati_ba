defmodule PratiBa.Repo.Migrations.AddEnabledToSources do
  use Ecto.Migration

  def change do
    alter table(:sources) do
      add :enabled, :boolean, null: false, default: true
    end

    create index(:sources, [:enabled])
  end
end
