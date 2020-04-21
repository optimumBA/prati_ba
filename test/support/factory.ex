defmodule PratiBa.Factory do
  use ExMachina.Ecto, repo: PratiBa.Repo

  alias PratiBa.Articles.{Article, Category, Source}

  def article_factory do
    %Article{
      url: sequence(:url, &"https://sourceurl.com/articles/#{&1}"),
      title: sequence(:title, &"Article #{&1}"),
      published_at: ~N[2020-03-11 07:44:00],
      image: nil,
      category: build(:category),
      source: build(:source),
    }
  end

  def category_factory do
    %Category{
      name: sequence(:name, &"Category-#{&1}"),
      order: sequence(:order, &"#{&1}")
    }
  end

  def source_factory do
    %Source{
      name: sequence(:name, &"Source-#{&1}"),
      url: sequence(:url, &"https://sourceurl-#{&1}.com")
    }
  end
end
