defmodule PratiBa.Repo.Migrations.DropVisitors do
  use Ecto.Migration

  def up do
    drop table(:visitors)
  end

  def down do
    create table(:visitors, primary_key: false) do
      add :id, :binary_id, primary_key: true

      timestamps()
    end
  end
end
