defmodule Store.Loyalty.ReferralTest do
  use Store.Case

  # @TODO DRY the dependent schema structs

  @valid_business params_for(:business)
  @valid_location params_for(:location)
  @valid_customer params_for(:customer)
  @valid_attrs params_for(:referral)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = Referral.changeset(%Referral{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = Referral.changeset(%Referral{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "recipient_phone is required" do
    referral = @valid_attrs |> Map.delete(:recipient_phone)
    changeset = Referral.changeset(%Referral{}, referral)
    refute changeset.valid?
    assert changeset.errors[:recipient_phone] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "is_completed is required" do
    referral = @valid_attrs |> Map.delete(:is_completed)
    changeset = Referral.changeset(%Referral{}, referral)
    refute changeset.valid?
    assert changeset.errors[:is_completed] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "from_customer_id is required" do
    referral = @valid_attrs |> Map.delete(:from_customer_id)
    changeset = Referral.changeset(%Referral{}, referral)
    refute changeset.valid?
    assert changeset.errors[:from_customer_id] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "business_id is required" do
    referral = @valid_attrs |> Map.delete(:business_id)
    changeset = Referral.changeset(%Referral{}, referral)
    refute changeset.valid?
    assert changeset.errors[:business_id] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "location_id is required" do
    referral = @valid_attrs |> Map.delete(:location_id)
    changeset = Referral.changeset(%Referral{}, referral)
    refute changeset.valid?
    assert changeset.errors[:location_id] == {"can't be blank", [validation: :required]}
  end

  @tag creates: "Schema creates"
  test "creating a valid Referral succeeds" do
    {:ok, business} = Business.create(@valid_business)

    location =
      @valid_location
      |> Map.put(:business_id, business.id)

    {:ok, location} = Location.create(location)
    {:ok, customer} = Customer.create(@valid_customer)

    referral =
      @valid_attrs
      |> Map.put(:business_id, business.id)
      |> Map.put(:location_id, location.id)
      |> Map.put(:from_customer_id, customer.id)

    {:ok, _} = Referral.create(referral)
  end

  @tag constraints: "Foreign keys"
  test "creating a Referral with an invalid business_id fails" do
    referral = @valid_attrs |> Map.put(:business_id, -1)
    {:error, changeset} = Referral.create(referral)

    assert changeset.errors[:business_id] ==
             {"does not exist",
              [constraint: :foreign, constraint_name: "referrals_business_id_fkey"]}
  end

  @tag constraints: "Foreign keys"
  test "creating a Referral with an invalid location_id fails" do
    {:ok, business} = Business.create(@valid_business)

    referral =
      @valid_attrs
      |> Map.put(:business_id, business.id)
      |> Map.put(:location_id, -1)

    {:error, changeset} = Referral.create(referral)

    assert changeset.errors[:location_id] ==
             {"does not exist",
              [constraint: :foreign, constraint_name: "referrals_location_id_fkey"]}
  end

  @tag constraints: "Foreign keys"
  test "creating a Referral with an invalid from_customer_id fails" do
    {:ok, business} = Business.create(@valid_business)

    location =
      @valid_location
      |> Map.put(:business_id, business.id)

    {:ok, location} = Location.create(location)

    referral =
      @valid_attrs
      |> Map.put(:business_id, business.id)
      |> Map.put(:location_id, location.id)
      |> Map.put(:from_customer_id, -1)

    {:error, changeset} = Referral.create(referral)

    assert changeset.errors[:from_customer_id] ==
             {"does not exist",
              [constraint: :foreign, constraint_name: "referrals_from_customer_id_fkey"]}
  end
end
