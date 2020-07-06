# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PratiBa.Repo.insert!(%PratiBa.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PratiBa.Repo
alias PratiBa.Articles.Source

import Ecto.Query, only: [from: 2]

sources = [
  %Source{name: "Dnevni avaz", url: "https://avaz.ba"},
  %Source{name: "Klix.ba", url: "https://www.klix.ba"},
  %Source{name: "radiosarajevo.ba", url: "https://radiosarajevo.ba"},
  %Source{name: "Raport.ba", url: "https://raport.ba"},
  %Source{name: "Žurnal", url: "https://zurnal.info"},
]

for source <- sources do
  query = from s in Source, where: s.name == ^source.name

  unless Repo.exists?(query) do
    Repo.insert!(source)
  end
end
