defmodule Store.Loyalty.RewardTest do
  use Store.Case

  @valid_attrs params_for(:reward)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "Valid changeset" do
    changeset = Reward.changeset(%Reward{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "Invalid changeset" do
    changeset = Reward.changeset(%Reward{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "name is required" do
    reward = @valid_attrs |> Map.delete(:name)
    changeset = Reward.changeset(%Reward{}, reward)
    refute changeset.valid?
    assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "type is required" do
    reward = @valid_attrs |> Map.delete(:type)
    changeset = Reward.changeset(%Reward{}, reward)
    refute changeset.valid?
    assert changeset.errors[:type] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "points is required" do
    reward = @valid_attrs |> Map.delete(:points)
    changeset = Reward.changeset(%Reward{}, reward)
    refute changeset.valid?
    assert changeset.errors[:points] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "is_active is required" do
    reward = @valid_attrs |> Map.delete(:is_active)
    changeset = Reward.changeset(%Reward{}, reward)
    refute changeset.valid?
    assert changeset.errors[:is_active] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Validate inclusion"
  test "changeset with invalid inclusion type" do
    reward = @valid_attrs |> Map.put(:type, "invalid")
    changeset = Reward.changeset(%Reward{}, reward)
    refute changeset.valid?
    assert changeset.errors[:type] == {"is invalid", [validation: :inclusion]}
  end
end
