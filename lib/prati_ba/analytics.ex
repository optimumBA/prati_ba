defmodule PratiBa.Analytics do
  @moduledoc """
  The Analytics context.
  """

  alias PratiBa.Analytics.{Event, EventType, Visit, Visitor}
  alias PratiBa.Repo

  @doc """
  Returns the list of visitors.

  ## Examples

      iex> list_visitors()
      [%Visitor{}, ...]

  """
  def list_visitors() do
    Visitor
    |> Repo.all()
  end

  @doc """
  Gets a single visitor.

  Returns `nil` if the Visitor does not exist.

  ## Examples

      iex> get_visitor("cb4d4710-f397-4741-8cca-33e886813738")
      %Visitor{}

      iex> get_visitor("11111111-f397-4741-8cca-33e886813738")
      nil

  """
  def get_visitor(id) do
    Visitor
    |> Repo.get(id)
  end

  @doc """
  Creates a visitor.

  ## Examples

      iex> create_visitor(%{field: value})
      {:ok, %Visitor{}}

      iex> create_visitor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_visitor() do
    %Visitor{}
    |> Repo.insert()
  end

  @doc """
  Returns the list of visits.

  ## Examples

      iex> list_visits()
      [%Visit{}, ...]

  """
  def list_visits() do
    Visit
    |> Repo.all()
    |> Repo.preload(:visitor)
  end

  @doc """
  Gets a single visit not older than 10 minutes.

  Returns `nil` if the Visit does not exist, or it's inactive, or doesn't belong to provided Visitor.

  ## Examples

      iex> get_visit(visitor, "cb4d4710-f397-4741-8cca-33e886813738")
      %Visitor{}

      iex> get_visit(visitor, "11111111-f397-4741-8cca-33e886813738")
      nil

  """
  def get_active_visit(%Visitor{id: visitor_id}, id) do
    Visit.active()
    |> Repo.get_by(id: id, visitor_id: visitor_id)
  end

  @doc """
  Creates a visit.

  ## Examples

      iex> create_visit(visitor, %{field: value})
      {:ok, %Visit{}}

      iex> create_visit(visitor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_visit(%Visitor{} = visitor, %{} = attrs) do
    %Visit{}
    |> Visit.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:visitor, visitor)
    |> Repo.insert()
  end

  @doc """
  Updates a visit.

  ## Examples

      iex> update_visit(visit, %{field: new_value})
      {:ok, %Visit{}}

      iex> update_visit(visit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_visit(%Visit{} = visit, attrs) do
    visit
    |> Visit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events() do
    Event
    |> Repo.all()
    |> Repo.preload(:event_type)
  end

  @doc """
  Creates an event.

  ## Examples

      iex> create_event(visit, event_type, %{field: value})
      {:ok, %Event{}}

      iex> create_event(visit, event_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(%Visit{} = visit, %EventType{} = event_type, %{} = attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:visit, visit)
    |> Ecto.Changeset.put_assoc(:event_type, event_type)
    |> Repo.insert()
  end

  @doc """
  Gets a single event type.

  Returns `nil` if the EventType does not exist.

  ## Examples

      iex> get_event_type("event_type_name")
      %Visitor{}

      iex> get_event_type("inexistent_event_type")
      nil

  """
  def get_event_type(name) do
    EventType
    |> Repo.get_by(name: name)
  end
end
