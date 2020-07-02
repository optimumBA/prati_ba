defmodule PratiBa.Repo.Migrations.DropCategories do
  use Ecto.Migration

  def change do
    drop table(:categories)
  end
end
