defmodule Store.Loyalty.DealTest do
  use Store.Case

  @valid_business params_for(:business)
  @valid_category params_for(:category)
  @valid_location params_for(:location)
  @valid_attrs params_for(:deal)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "valid Deal changeset" do
    changeset = Deal.changeset(%Deal{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "invalid Deal changeset" do
    changeset = Deal.changeset(%Deal{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "business_id is required" do
    invalid_deal = @valid_attrs |> Map.delete(:business_id)
    changeset = Deal.changeset(%Deal{}, invalid_deal)
    assert changeset.errors[:business_id] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "name is required" do
    invalid_deal = @valid_attrs |> Map.delete(:name)
    changeset = Deal.changeset(%Deal{}, invalid_deal)
    assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
  end

  @tag creates: "Schema creates"
  test "create a valid deal" do
    {:ok, business} = Business.create(@valid_business)

    {:ok, location} =
      @valid_location
      |> Map.put(:business_id, business.id)
      |> Location.create()

    category =
      @valid_category
      |> Map.put(:business_id, business.id)

    {:ok, category} = Category.create(category)

    valid_deal =
      @valid_attrs
      |> Map.put(:location_id, location.id)
      |> Map.put(:business_id, business.id)
      |> Map.put(:category_id, category.id)

    {:ok, _} = Deal.create(valid_deal)
  end

  @tag constraints: "Foreign keys"
  test "create a deal fails if business_id is not provided" do
    {:ok, business} = Business.create(@valid_business)

    location =
      @valid_location
      |> Map.put(:business_id, business.id)

    {:ok, location} = Location.create(location)

    category =
      @valid_category
      |> Map.put(:business_id, business.id)

    {:ok, category} = Category.create(category)

    deal =
      @valid_attrs
      |> Map.put(:business_id, -1)
      |> Map.put(:location_id, location.id)
      |> Map.put(:category_id, category.id)

    {:error, changeset} = Deal.create(deal)

    assert changeset.errors[:business_id] ==
             {"does not exist", [constraint: :foreign, constraint_name: "deals_business_id_fkey"]}
  end
end
