defmodule PratiBa.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :visitor_id, references(:visitors, on_delete: :delete_all, type: :binary_id),
        null: false

      add :path, :string, null: false
      add :referer, :string
      add :isp, :string
      add :geo, :map
      add :user_agent, :map
      add :raw, :map, null: false

      timestamps()
    end

    create index(:requests, [:visitor_id])
  end
end
