defmodule Store.MemberGroupTest do
  use Store.Case

  @valid_attrs params_for(:membergroup)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "MemberGroup changeset is valid" do
    changeset = MemberGroup.changeset(%MemberGroup{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Required fields"
  test "name is required" do
    changeset = MemberGroup.changeset(%MemberGroup{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag creates: "Schema creates"
  test "create a MemberGroup succeeds if valid" do
    {:ok, _} = MemberGroup.create(@valid_attrs)
  end

  @tag constraints: "Unique constraint"
  test "Cannot have two MemberGroup records with the same name" do
    {:ok, _} = MemberGroup.create(@valid_attrs)
    {:error, changeset} = MemberGroup.create(@valid_attrs)

    assert changeset.errors[:name] ==
             {"has already been taken",
              [constraint: :unique, constraint_name: "member_groups_name_index"]}
  end
end
