defmodule Store.HistoryTest do
  use Store.Case

  @valid_attrs params_for(:history)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "valid changeset" do
    changeset = History.changeset(%History{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Valid struct"
  test "invalid changeset" do
    changeset = History.changeset(%History{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "action is required" do
    history = @valid_attrs |> Map.delete(:action)
    changeset = History.changeset(%History{}, history)
    refute changeset.valid?
    assert changeset.errors[:action] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "type is required" do
    history = @valid_attrs |> Map.delete(:type)
    changeset = History.changeset(%History{}, history)
    refute changeset.valid?
    assert changeset.errors[:type] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "meta is required" do
    history = @valid_attrs |> Map.delete(:meta)
    changeset = History.changeset(%History{}, history)
    refute changeset.valid?
    assert changeset.errors[:meta] == {"can't be blank", [validation: :required]}
  end

  @tag creates: "Schema creates"
  test "create a valid History record" do
    {:ok, _} = History.create(@valid_attrs)
  end
end
