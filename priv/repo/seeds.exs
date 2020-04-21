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
alias PratiBa.Articles.{Category, Source}

import Ecto.Query, only: [from: 2]

sources = [
  %Source{name: "Klix.ba", url: "https://www.klix.ba"},
  %Source{name: "radiosarajevo.ba", url: "https://radiosarajevo.ba"},
]

for source <- sources do
  query = from s in Source, where: s.name == ^source.name

  unless Repo.exists?(query) do
    Repo.insert!(source)
  end
end

categories = [
  %Category{name: "BiH", order: 0},
  %Category{name: "Regija", order: 1},
  %Category{name: "Svijet", order: 2},
  %Category{name: "Ekonomija", order: 3},
  %Category{name: "Nauka i tehnologija", order: 4},
  %Category{name: "Kolumne", order: 5},
  %Category{name: "Sport", order: 6},
  %Category{name: "Auto", order: 7},
  %Category{name: "Humanost", order: 8},
  %Category{name: "Zabava", order: 9},
]

for category <- categories do
  query = from c in Category, where: c.name == ^category.name

  unless Repo.exists?(query) do
    Repo.insert!(category)
  end
end
