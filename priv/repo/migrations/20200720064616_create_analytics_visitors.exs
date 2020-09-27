defmodule PratiBa.Repo.Migrations.CreateAnalyticsVisitors do
  use Ecto.Migration

  def change do
    create table(:analytics_visitors, primary_key: false) do
      add :id, :binary_id, primary_key: true

      timestamps()
    end
  end
end
