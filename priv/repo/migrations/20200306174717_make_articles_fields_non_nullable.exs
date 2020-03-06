defmodule PratiBa.Repo.Migrations.MakeArticlesFieldsNonNullable do
  use Ecto.Migration

  def change do
    alter table(:articles) do
      modify :title, :string, null: false
      modify :url, :string, null: false
      modify :published_at, :naive_datetime, null: false
    end
  end
end
