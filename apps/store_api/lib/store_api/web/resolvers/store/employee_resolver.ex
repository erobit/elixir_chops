defmodule StoreAPI.Resolvers.Employee do
  alias Store
  alias Store.Utility.Security, as: Security

  def me(_, %{context: %{employee: employee}}) do
    case Store.get_employee_customer(employee.id) do
      nil -> {:error, "No employee found."}
      e -> {:ok, e}
    end
  end

  def create(employee_obj, %{context: %{employee: employee}}) do
    employee_struct = Map.put(employee_obj, :business_id, employee.business_id)

    case Store.create_employee(employee_struct) do
      {:error, msg} -> {:error, msg}
      {:ok, employee} -> {:ok, employee}
    end
  end

  def login(%{email: email, password: password}, %{context: %{subdomain: subdomain}}) do
    with {:ok, employee} <- Store.authenticate(subdomain, email, password),
         {:ok, jwt, _} <- CRM.Guardian.encode_and_sign(employee, token_type: :access) do
      {:ok, %{token: jwt}}
    end
  end

  def get_employees(_parent, options, %{context: %{employee: employee}}) do
    location_ids =
      employee.locations
      |> Enum.filter(fn l -> l.is_active end)
      |> Enum.map(fn l -> l.id end)

    case Store.get_employees(employee.business_id, location_ids, options) do
      [] -> {:error, "No employees returned for Business #{employee.business_id}"}
      {:error, error} -> {:error, "Cannot get Employees: #{error}"}
      {:ok, employees} -> {:ok, employees}
    end
  end

  def toggle_active(%{id: id, is_active: is_active}, %{context: %{employee: _}}) do
    Store.toggle_active(Store.Employee, id, is_active)
  end

  def get_reset(%{id: id}, %{context: %{employee: _employee}}) do
    case Store.get_employee_reset(id) do
      nil -> {:error, "reset not found"}
      _ -> {:ok, %{id: id}}
    end
  end

  def employee_reset(%{email: email}, %{context: %{subdomain: subdomain}}) do
    case Store.employee_reset(email, subdomain) do
      {:ok, reset} -> {:ok, %{email: reset.email}}
      {:error, error} -> {:error, error}
    end
  end

  def password_strength(%{password: password}, _info) do
    Security.check_password_strength(password)
  end

  def reset_password(%{id: id, password: password}, _info) do
    case Store.set_employee_password(id, password) do
      {:ok, reset} -> {:ok, %{email: reset.email, strength: reset.strength}}
      {:error, error} -> {:error, error}
    end
  end

  def get_session_from_token(%{authorization_token: token}, _) do
    employee = Store.get_admin_user_from_token(token)

    case CRM.Guardian.encode_and_sign(employee, token_type: :acess) do
      {:ok, jwt, _} -> {:ok, %{token: jwt}}
      err -> err
    end
  end

  def create_customer_export_email(%{type: type}, %{context: %{employee: employee}}) do
    Store.send_customer_export_email(employee.business, employee, type)
  end
end
