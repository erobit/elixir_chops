defmodule Store.CustomerTest do
  use Store.Case

  @valid_attrs params_for(:customer)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = Customer.changeset(%Customer{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = Customer.changeset(%Customer{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "changeset invalid if phone is not provided" do
    invalid = @valid_attrs |> Map.delete(:phone)
    changeset = Customer.changeset(%Customer{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:phone] == {"can't be blank", [validation: :required]}
  end

  @tag creates: "Schema creates"
  test "inserting a valid customer succeeds" do
    {:ok, _} = Customer.create(@valid_attrs)
  end

  @tag creates: "Schema creates"
  test "inserting an invalid customer fais" do
    {:error, _} = Customer.create(@invalid_attrs)
  end

  @tag constraints: "Unique constraint"
  test "cannot insert a customer with the same phone number" do
    {:ok, _} = Customer.create(@valid_attrs)
    {:error, changeset} = Customer.create(@valid_attrs)

    assert changeset.errors[:phone] ==
             {"has already been taken",
              [constraint: :unique, constraint_name: "customers_phone_index"]}
  end

  @tag constraints: "Unique constraint"
  test "cannot insert a customer with the same email" do
    struct = @valid_attrs |> Map.put(:phone, "1-222-333-4444")
    {:ok, _} = Customer.create(@valid_attrs)
    {:error, changeset} = Customer.create(struct)

    assert changeset.errors[:email] ==
             {"has already been taken",
              [constraint: :unique, constraint_name: "customers_email_index"]}
  end
end
