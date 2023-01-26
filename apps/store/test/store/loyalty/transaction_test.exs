defmodule Store.Loyalty.TransactionTest do
  use Store.Case

  @valid_business params_for(:business)
  @valid_customer params_for(:customer)
  @valid_location params_for(:location)
  @valid_attrs params_for(:transaction)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "location_id is required" do
    transaction = @valid_attrs |> Map.delete(:location_id)
    changeset = Transaction.changeset(%Transaction{}, transaction)
    refute changeset.valid?
    assert changeset.errors[:location_id] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "customer_id is required" do
    transaction = @valid_attrs |> Map.delete(:customer_id)
    changeset = Transaction.changeset(%Transaction{}, transaction)
    refute changeset.valid?
    assert changeset.errors[:customer_id] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "type is required" do
    transaction = @valid_attrs |> Map.delete(:type)
    changeset = Transaction.changeset(%Transaction{}, transaction)
    refute changeset.valid?
    assert changeset.errors[:type] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "units is required" do
    transaction = @valid_attrs |> Map.delete(:units)
    changeset = Transaction.changeset(%Transaction{}, transaction)
    refute changeset.valid?
    assert changeset.errors[:units] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Validate inclusion"
  test "changeset with invalid inclusion type" do
    transaction = @valid_attrs |> Map.put(:type, "invalid")
    changeset = Transaction.changeset(%Transaction{}, transaction)
    refute changeset.valid?
    assert changeset.errors[:type] == {"is invalid", [validation: :inclusion]}
  end

  @tag creates: "Schema creates"
  test "creating a valid Transaction succeeds" do
    {:ok, business} = Business.create(@valid_business)
    {:ok, customer} = Customer.create(@valid_customer)
    valid_location = @valid_location |> Map.put(:business_id, business.id)
    {:ok, location} = Location.create(valid_location)

    transaction =
      @valid_attrs
      |> Map.put(:customer_id, customer.id)
      |> Map.put(:location_id, location.id)

    {:ok, _} = Transaction.create(transaction)
  end

  @tag constraints: "Foreign keys"
  test "creating a Transaction with an invalid customer_id fails" do
    {:ok, business} = Business.create(@valid_business)
    valid_location = @valid_location |> Map.put(:business_id, business.id)
    {:ok, location} = Location.create(valid_location)

    transaction =
      @valid_attrs
      |> Map.put(:location_id, location.id)
      |> Map.put(:customer_id, -1)

    {:error, changeset} = Transaction.create(transaction)

    assert changeset.errors[:customer_id] ==
             {"does not exist",
              [constraint: :foreign, constraint_name: "transactions_customer_id_fkey"]}
  end

  @tag constraints: "Foreign keys"
  test "creating a Transaction with an invalid location_id fails" do
    {:ok, customer} = Customer.create(@valid_customer)

    transaction =
      @valid_attrs
      |> Map.put(:customer_id, customer.id)
      |> Map.put(:location_id, -1)

    {:error, changeset} = Transaction.create(transaction)

    assert changeset.errors[:location_id] ==
             {"does not exist",
              [constraint: :foreign, constraint_name: "transactions_location_id_fkey"]}
  end
end
