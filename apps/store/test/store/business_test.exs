defmodule Store.BusinessTest do
  use Store.Case

  @valid_attrs params_for(:business)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = Business.changeset(%Business{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = Business.changeset(%Business{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Validate inclusion"
  test "changeset with invalid inclusion type" do
    point = @valid_attrs |> Map.put(:type, "invalid")
    changeset = Business.changeset(%Business{}, point)
    refute changeset.valid?
    assert changeset.errors[:type] == {"is invalid", [validation: :inclusion]}
  end

  @tag changesets: "Required fields"
  test "changeset invalid if type is not provided" do
    invalid = @valid_attrs |> Map.delete(:type)
    changeset = Business.changeset(%Business{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:type] == {"can't be blank", [validation: :required]}
  end

  @tag creates: "Schema creates"
  test "inserting a valid changeset succeeds" do
    valid_changeset = Business.changeset(%Business{}, @valid_attrs)
    assert {:ok, _} = Repo.insert(valid_changeset)
  end

  @tag creates: "Schema creates"
  test "inserting an invalid changeset fails" do
    invalid_changeset = Business.changeset(%Business{}, @invalid_attrs)
    assert {:error, _} = Repo.insert(invalid_changeset)
  end
end
