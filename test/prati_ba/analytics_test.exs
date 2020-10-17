defmodule PratiBa.AnalyticsTest do
  use PratiBa.DataCase, async: true

  alias PratiBa.Analytics
  alias PratiBa.Analytics.{Event, EventType, Visit, Visitor}

  def visitor_fixture() do
    {:ok, %Visitor{} = visitor} = Analytics.create_visitor()

    visitor
  end

  describe "visitors" do
    test "list_visitors/0 returns all visitors" do
      visitor = visitor_fixture()
      assert Analytics.list_visitors() == [visitor]
    end

    test "get_visitor/1 returns the visitor with given ID" do
      visitor = visitor_fixture()
      assert ^visitor = Analytics.get_visitor(visitor.id)
    end

    test "get_visitor/1 returns nil when given wrong ID" do
      wrong_id = Ecto.UUID.generate()
      refute Analytics.get_visitor(wrong_id)
    end

    test "create_visitor/1" do
      assert {:ok, %Visitor{}} = Analytics.create_visitor()
    end
  end

  describe "visits" do
    @valid_attrs %{started_at: NaiveDateTime.utc_now(), last_active_at: NaiveDateTime.utc_now()}
    @invalid_attrs %{started_at: nil, last_active_at: nil}

    def visit_fixture(visitor, attrs \\ %{}) do
      attrs = Map.merge(@valid_attrs, attrs)
      {:ok, %Visit{} = visit} = Analytics.create_visit(visitor, attrs)

      visit
    end

    test "list_visits/0 returns all visits" do
      visitor = visitor_fixture()
      visit = visit_fixture(visitor)
      assert Analytics.list_visits() == [visit]
    end

    test "get_active_visit/2 returns the visit with given ID" do
      visitor = visitor_fixture()
      visit = visit_fixture(visitor)
      assert returned_visit = Analytics.get_active_visit(visitor, visit.id)
      assert returned_visit.id == visit.id
      assert returned_visit.visitor_id == visitor.id
    end

    test "get_active_visit/2 returns nil when given wrong visitor" do
      visitor = visitor_fixture()
      visit = visit_fixture(visitor)
      another_visitor = visitor_fixture()
      refute Analytics.get_active_visit(another_visitor, visit.id)
    end

    test "get_active_visit/2 returns nil when given wrong ID" do
      visitor = visitor_fixture()
      visit_fixture(visitor)
      wrong_id = Ecto.UUID.generate()
      refute Analytics.get_active_visit(visitor, wrong_id)
    end

    test "get_active_visit/2 returns nil when visit was not active for 10 minutes" do
      eleven_minutes_ago =
        DateTime.utc_now()
        |> DateTime.add(-11 * 60)
        |> DateTime.to_naive()

      visitor = visitor_fixture()
      visit = visit_fixture(visitor, %{last_active_at: eleven_minutes_ago})
      refute Analytics.get_active_visit(visitor, visit.id)
    end

    test "create_visit/2 with valid data creates visit" do
      visitor = visitor_fixture()
      assert {:ok, %Visit{} = visit} = Analytics.create_visit(visitor, @valid_attrs)
      assert ^visitor = visit.visitor
    end

    test "create_visit/2 with invalid data returns error changeset" do
      visitor = visitor_fixture()
      assert {:error, %Ecto.Changeset{}} = Analytics.create_visit(visitor, @invalid_attrs)
    end

    test "update_visit/2 with valid data updates visit" do
      visitor = visitor_fixture()
      visit = visit_fixture(visitor)
      assert {:ok, %Visit{} = updated_visit} = Analytics.update_visit(visit, %{isp: "Telemach"})
      assert updated_visit.id == visit.id
      assert updated_visit.isp == "Telemach"
    end

    test "update_visit/2 with invalid data returns error changeset" do
      visitor = visitor_fixture()
      visit = visit_fixture(visitor)
      assert {:error, %Ecto.Changeset{}} = Analytics.update_visit(visit, @invalid_attrs)
      assert visit == Analytics.get_active_visit(visitor, visit.id) |> Repo.preload(:visitor)
    end
  end

  describe "events" do
    @valid_attrs %{requested_at: NaiveDateTime.utc_now()}
    @invalid_attrs %{requested_at: nil}

    test "list_events/0 returns all events with event types" do
      event_type = insert(:event_type, name: "some_great_event")
      insert(:event, event_type: event_type)
      assert [%Event{event_type: %EventType{name: "some_great_event"}}] = Analytics.list_events()
    end

    test "create_event/3 with valid data creates event" do
      visit = insert(:visit)
      event_type = insert(:event_type)

      assert {:ok, %Event{} = event} = Analytics.create_event(visit, event_type, @valid_attrs)
      assert ^visit = event.visit
      assert ^event_type = event.event_type
    end

    test "create_event/3 with invalid data returns error changeset" do
      visit = insert(:visit)
      event_type = insert(:event_type)

      assert {:error, %Ecto.Changeset{}} =
               Analytics.create_event(visit, event_type, @invalid_attrs)
    end
  end

  describe "event_types" do
    test "get_event_type/1 returns the event type with the given name" do
      event_type = insert(:event_type, name: "new_event_type")
      assert loaded_event_type = Analytics.get_event_type("new_event_type")
      assert loaded_event_type.id == event_type.id
      assert loaded_event_type.name == event_type.name
    end

    test "get_event_type/1 returns nil when given wrong name" do
      refute Analytics.get_event_type("inexistent_event_type")
    end
  end
end
