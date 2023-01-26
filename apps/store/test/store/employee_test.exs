defmodule Store.EmployeeTest do
  use Store.Case

  @valid_business params_for(:business)
  @valid_attrs params_for(:employee)
  @invalid_attrs %{}

  @tag changesets: "Valid struct"
  test "changeset with valid attributes" do
    changeset = Employee.changeset(%Employee{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag changesets: "Invalid struct"
  test "changeset with invalid attributes" do
    changeset = Employee.changeset(%Employee{}, @invalid_attrs)
    refute changeset.valid?
  end

  @tag changesets: "Required fields"
  test "changeset invalid if email is not provided" do
    invalid = @valid_attrs |> Map.delete(:email)
    changeset = Employee.changeset(%Employee{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:email] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Required fields"
  test "changeset invalid if role is not provided" do
    invalid = @valid_attrs |> Map.delete(:role)
    changeset = Employee.changeset(%Employee{}, invalid)
    refute changeset.valid?
    assert changeset.errors[:role] == {"can't be blank", [validation: :required]}
  end

  @tag changesets: "Validate inclusion"
  test "changeset with invalid inclusion type" do
    employee = @valid_attrs |> Map.put(:role, "invalid")
    changeset = Employee.changeset(%Employee{}, employee)
    refute changeset.valid?
    assert changeset.errors[:role] == {"is invalid", [validation: :inclusion]}
  end

  @tag creates: "Schema creates"
  test "inserting a valid employee succeeds" do
    {:ok, business} = Business.create(@valid_business)
    employee = @valid_attrs |> Map.put(:business_id, business.id)
    {:ok, _} = Employee.create(employee)
  end

  @tag creates: "Schema creates"
  test "inserting an invalid employee fails" do
    {:error, _} = Employee.create(@invalid_attrs)
  end

  @tag creates: "Schema creates with hash_password"
  test "creating a new employee generates a hash_password" do
    {:ok, business} = Business.create(@valid_business)

    employee =
      @valid_attrs
      |> Map.put(:business_id, business.id)
      |> Map.put(:password, "test")

    {:ok, employee} = Employee.create(employee)
    refute employee.password_hash == nil
    refute employee.password == employee.password_hash
  end

  @tag constraints: "Unique constraint"
  test "cannot insert a customer with the same email" do
    {:ok, business} = Business.create(@valid_business)

    employee =
      @valid_attrs
      |> Map.put(:business_id, business.id)
      |> Map.put(:phone, "1-222-333-4444")

    {:ok, _} = Employee.create(employee)
    {:error, changeset} = Employee.create(employee)

    assert changeset.errors[:email] ==
             {"has already been taken",
              [constraint: :unique, constraint_name: "employees_email_business_id_index"]}
  end
end
