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

alias PratiBa.Analytics.EventType
alias PratiBa.Articles.Source
alias PratiBa.Repo

import Ecto.Query, only: [from: 2]

sources = [
  %Source{name: "BH Dani", url: "https://bhdani.oslobodjenje.ba/bhdani/"},
  %Source{name: "Bljesak.info", url: "https://www.bljesak.info"},
  %Source{name: "CIN", url: "https://www.cin.ba"},
  %Source{name: "Dnevni avaz", url: "https://avaz.ba"},
  %Source{name: "DW", url: "https://www.dw.com/bs/teme/s-10037"},
  %Source{name: "face.ba", url: "https://www.face.ba"},
  %Source{name: "Fokus.ba", url: "https://www.fokus.ba"},
  %Source{name: "Klix.ba", url: "https://www.klix.ba"},
  %Source{name: "N1", url: "https://ba.n1info.com"},
  %Source{name: "Nezavisne novine", url: "https://www.nezavisne.com"},
  %Source{name: "Oslobođenje", url: "https://www.oslobodjenje.ba"},
  %Source{name: "Prva smjena", url: "http://prvasmjena.com"},
  %Source{name: "Radio Sarajevo", url: "https://radiosarajevo.ba"},
  %Source{name: "Radio Slobodna Evropa", url: "https://www.slobodnaevropa.org"},
  %Source{name: "Raport.ba", url: "https://raport.ba"},
  %Source{name: "Raskrinkavanje.ba", url: "https://raskrinkavanje.ba"},
  %Source{name: "Slobodna Bosna", url: "https://www.slobodna-bosna.ba"},
  %Source{name: "source.ba", url: "http://source.ba"},
  %Source{name: "The Bosnia Times", url: "https://thebosniatimes.ba"},
  %Source{name: "Žurnal", url: "https://zurnal.info"}
]

for source <- sources do
  query = from(s in Source, where: s.name == ^source.name)

  unless Repo.exists?(query) do
    Repo.insert!(source)
  end
end

event_types = [
  %EventType{name: "article_view"},
  %EventType{name: "page_view"}
]

for event_type <- event_types do
  query = from(et in EventType, where: et.name == ^event_type.name)

  unless Repo.exists?(query) do
    Repo.insert!(event_type)
  end
end
