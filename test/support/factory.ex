defmodule PratiBa.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: PratiBa.Repo

  alias PratiBa.Analytics.Event
  alias PratiBa.Analytics.EventType
  alias PratiBa.Analytics.Visit
  alias PratiBa.Analytics.Visitor
  alias PratiBa.Articles.Article
  alias PratiBa.Articles.Source

  @spec article_factory() :: Article.t()
  def article_factory do
    %Article{
      image: nil,
      original_id: sequence(:original_id, &Integer.to_string/1),
      published_at: ~N[2020-03-11 07:44:00],
      source: build(:source),
      title: sequence(:title, &"Article #{&1}"),
      url: sequence(:url, &"https://sourceurl.com/articles/#{&1}")
    }
  end

  @spec source_factory() :: Source.t()
  def source_factory do
    %Source{
      name: sequence(:name, &"Source-#{&1}"),
      url: sequence(:url, &"https://sourceurl-#{&1}.com"),
      enabled: true
    }
  end

  @spec visitor_factory() :: Visitor.t()
  def visitor_factory do
    %Visitor{}
  end

  @spec visit_factory() :: Visit.t()
  def visit_factory do
    %Visit{
      last_active_at: NaiveDateTime.utc_now(),
      started_at: NaiveDateTime.utc_now(),
      visitor: build(:visitor)
    }
  end

  @spec event_type_factory() :: EventType.t()
  def event_type_factory do
    %EventType{
      name: sequence(:name, &"event_type-#{&1}")
    }
  end

  @spec event_factory() :: Event.t()
  def event_factory do
    %Event{
      event_type: build(:event_type),
      visit: build(:visit)
    }
  end
end
