defmodule Store.LocationTest do
  use Store.Case

  @valid_attrs params_for(:location)
  @valid_business params_for(:business)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = Location.changeset(%Location{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = Location.changeset(%Location{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "changeset invalid if name is not provided" do
    invalid = @valid_attrs |> Map.delete(:name)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert name: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if address is not provided" do
    invalid = @valid_attrs |> Map.delete(:address)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert address: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if city is not provided" do
    invalid = @valid_attrs |> Map.delete(:city)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert city: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if province is not provided" do
    invalid = @valid_attrs |> Map.delete(:province)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert province: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if postal_code is not provided" do
    invalid = @valid_attrs |> Map.delete(:postal_code)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert postal_code: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if phone is not provided" do
    invalid = @valid_attrs |> Map.delete(:phone)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert phone: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if hero is not provided" do
    invalid = @valid_attrs |> Map.delete(:hero)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert hero: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if logo is not provided" do
    invalid = @valid_attrs |> Map.delete(:logo)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert logo: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag changesets: "Required fields"
  test "changeset invalid if business_id is not provided" do
    invalid = @valid_attrs |> Map.delete(:business_id)
    changeset = Location.changeset(%Location{}, invalid)
    refute changeset.valid?
    assert business_id: {"can't be blank", [validation: :required]} in changeset.errors
  end

  @tag creates: "Schema creates"
  test "creating a valid location succeeds" do
    {:ok, business} = Business.create(@valid_business)
    valid_location = @valid_attrs |> Map.put(:business_id, business.id)
    assert {:ok, _} = Location.create(valid_location)
  end

  @tag constraints: "Foreign keys"
  test "createing a location with an invalid business_id fails" do
    invalid_location = @valid_attrs |> Map.put(:business_id, 2_147_483_647)
    assert {:error, changeset} = Location.create(invalid_location)

    assert changeset.errors[:business_id] ==
             {"does not exist",
              [constraint: :foreign, constraint_name: "locations_business_id_fkey"]}
  end

  # @TODO We should add database integrity field checks for all the
  # fields set to null: false, to ensure that nulls are not allowed
end
