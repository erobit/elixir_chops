defmodule Store.Inventory.CategoryTest do
  use Store.Case

  @valid_attrs params_for(:category)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "valid changeset" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "invalid changeset" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "name is required" do
    category = @valid_attrs |> Map.delete(:name)
    changeset = Category.changeset(%Category{}, category)
    refute changeset.valid?
    assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
  end

  @tag creates: "Schema creates"
  test "valid create" do
    {:ok, _} = Category.create(@valid_attrs)
  end
end
