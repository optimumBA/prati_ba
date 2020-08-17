defmodule PratiBa.Factory do
  use ExMachina.Ecto, repo: PratiBa.Repo

  alias PratiBa.Articles.{Article, Source}

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

  def source_factory do
    %Source{
      name: sequence(:name, &"Source-#{&1}"),
      url: sequence(:url, &"https://sourceurl-#{&1}.com"),
      enabled: true
    }
  end
end
