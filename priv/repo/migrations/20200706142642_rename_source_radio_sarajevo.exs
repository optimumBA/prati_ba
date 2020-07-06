defmodule PratiBa.Repo.Migrations.RenameSourceRadioSarajevo do
  use Ecto.Migration

  alias PratiBa.Repo
  alias PratiBa.Articles.Source

  def up do
    case Repo.get_by(Source, name: "radiosarajevo.ba") do
      {:ok, source} ->
        source
        |> Ecto.Changeset.change(name: "Radio Sarajevo")
        |> Repo.update!()

      _ ->
        nil
    end
  end

  def down do
    case Repo.get_by(Source, name: "Radio Sarajevo") do
      {:ok, source} ->
        source
        |> Ecto.Changeset.change(name: "radiosarajevo.ba")
        |> Repo.update!()

      _ ->
        nil
    end
  end
end
