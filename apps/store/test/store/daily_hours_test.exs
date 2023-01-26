defmodule Store.DailyHoursTest do
  use Store.Case

  @valid_attrs %{weekday: "mon", start: "00:00", end: "00:00", closed: false}
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = DailyHours.changeset(%DailyHours{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = DailyHours.changeset(%DailyHours{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "changeset invalid if weekday is not provided" do
    invalid = @valid_attrs |> Map.delete(:weekday)
    changeset = DailyHours.changeset(%DailyHours{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:weekday] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "changeset invalid if start is not provided" do
    invalid = @valid_attrs |> Map.delete(:start)
    changeset = DailyHours.changeset(%DailyHours{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:start] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "changeset invalid if end is not provided" do
    invalid = @valid_attrs |> Map.delete(:end)
    changeset = DailyHours.changeset(%DailyHours{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:end] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "changeset invalid if closed is not provided" do
    invalid = @valid_attrs |> Map.delete(:closed)
    changeset = DailyHours.changeset(%DailyHours{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:closed] == {"can't be blank", [validation: :required]}
  end
end
