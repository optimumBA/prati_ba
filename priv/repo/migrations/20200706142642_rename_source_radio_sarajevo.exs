defmodule PratiBa.Repo.Migrations.RenameSourceRadioSarajevo do
  use Ecto.Migration

  alias PratiBa.Repo

  def up do
    Repo.query("UPDATE \"sources\" SET name = $1 WHERE name = $2", [
      "Radio Sarajevo",
      "radiosarajevo.ba"
    ])
  end

  def down do
    Repo.query("UPDATE \"sources\" SET name = $1 WHERE name = $2", [
      "radiosarajevo.ba",
      "Radio Sarajevo"
    ])
  end
end
