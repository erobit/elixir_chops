defmodule Store.MembershipTest do
  use Store.Case

  @valid_business params_for(:business)
  @valid_business2 params_for(:business)
  @valid_customer params_for(:customer)
  @valid_attrs params_for(:membership)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = Membership.changeset(%Membership{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = Membership.changeset(%Membership{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag creates: "Schema creates"
  test "create a valid member succeeds" do
    {:ok, business} = Business.create(@valid_business)
    {:ok, customer} = Customer.create(@valid_customer)

    {:ok, _} =
      @valid_attrs
      |> Map.put(:business_id, business.id)
      |> Map.put(:customer_id, customer.id)
      |> Membership.create()
  end

  @tag constraints: "Unique constraint"
  test "cannot add the same customer to the same business as a member" do
    {:ok, business} = Business.create(@valid_business)
    {:ok, customer} = Customer.create(@valid_customer)

    valid_member =
      @valid_attrs
      |> Map.put(:business_id, business.id)
      |> Map.put(:customer_id, customer.id)

    {:ok, _} = Membership.create(valid_member)
    {:error, changeset} = Membership.create(valid_member)

    assert changeset.errors[:business_id] ==
             {"has already been taken",
              [constraint: :unique, constraint_name: "members_business_id_customer_id_index"]}
  end

  @tag constraints: "Unique constraint"
  test "can add the same customer as a member to different businesses" do
    {:ok, first_business} = Business.create(@valid_business)
    {:ok, second_business} = Business.create(@valid_business2)
    {:ok, customer} = Customer.create(@valid_customer)

    valid_member =
      @valid_attrs
      |> Map.put(:business_id, first_business.id)
      |> Map.put(:customer_id, customer.id)

    {:ok, _} = Membership.create(valid_member)

    {:ok, _} =
      valid_member
      |> Map.put(:business_id, second_business.id)
      |> Membership.create()
  end
end
