defmodule PratiBa.Repo.Migrations.CreateVisitors do
  use Ecto.Migration

  def change do
    create table(:visitors, primary_key: false) do
      add :id, :binary_id, primary_key: true

      timestamps()
    end

  end
end
