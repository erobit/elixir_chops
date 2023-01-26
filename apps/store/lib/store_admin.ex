defmodule StoreAdmin do
  use Store.Model
  alias Store.Utility.Security, as: Security

  ## change this to authenticate against the AcmeEmployee object instead
  def authenticate(email, password, repo \\ Repo) do
    AdminEmployee.authenticate(email, password, repo)
  end

  def get_employee(id) do
    AdminEmployee.get(id)
  end

  def get_all_admins(options) do
    AdminEmployee.get_all(options)
  end

  def get_employee_reset(id) do
    AdminEmployeeReset.get(id)
  end

  def employee_reset(email, subdomain) do
    case AdminEmployee.get_by_email(email) do
      nil -> {:error, "Employee record not found"}
      employee -> create_reset(%{employee: employee}, subdomain)
    end
  end

  def set_employee_password(id, password, ip_address \\ "") do
    case Security.check_password_strength(password) do
      {:error, message} ->
        {:error, message}

      {:ok, %{score: score, message: message}} ->
        reset = AdminEmployeeReset.get(id)

        multi =
          Multi.new()
          |> Multi.update(
            :employee,
            AdminEmployee.password_reset_changeset(reset.email, password)
          )
          |> Multi.update(:employee_reset, AdminEmployeeReset.used_changeset(id, ip_address))

        case Repo.transaction(multi) do
          {:ok, %{employee: _employee, employee_reset: _reset}} ->
            {:ok, %{email: reset.email, strength: %{score: score, message: message}}}

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            {:error, failed_value}
        end
    end
  end

  def create_business(business) do
    Business.create(business)
  end

  def create_employee(employee, subdomain) do
    case Map.has_key?(employee, :id) do
      true ->
        AdminEmployee.create(employee)

      false ->
        employee_changeset = AdminEmployee.changeset(%AdminEmployee{}, employee)
        employee_changeset = employee_changeset |> AdminEmployee.put_password_hash()

        multi =
          Multi.new()
          |> Multi.insert(:employee, employee_changeset)
          |> Multi.run(:employee_reset, fn arg -> create_reset(arg, subdomain) end)

        case Repo.transaction(multi) do
          {:ok, %{employee: employee, employee_reset: _reset}} ->
            {:ok, employee}

          {:error, _failed_operation, failed_value, _changes_so_far} ->
            {:error, failed_value}
        end
    end
  end

  defp create_reset(%{employee: employee}, subdomain) do
    reset = %{
      employee_id: employee.id,
      email: employee.email,
      sent: false,
      used: false
    }

    case AdminEmployeeReset.create(reset) do
      {:ok, admin_reset} ->
        send_reset_email(admin_reset, subdomain)
        {:ok, admin_reset}

      {:error, error} ->
        {:error, error}
    end
  end

  defp send_reset_email(admin_reset, subdomain) do
    admin_reset
    |> EmployeeEmail.admin_password_reset_email(subdomain)
    |> Store.Mailer.deliver()
    |> mark_as_sent(admin_reset.id)
  end

  defp mark_as_sent(result, id) do
    case result do
      {:ok, _result} -> AdminEmployeeReset.sent(id)
      {:error, error} -> {:error, error}
    end
  end

  def provision(email, phone, name, subdomain, type, language) do
    employee = %{email: email, phone: phone, role: "owner", is_active: true}

    business = %{
      name: name,
      subdomain: subdomain,
      type: type,
      is_verified: true,
      language: language
    }

    admin = %{
      email: "superadmin@super.admin",
      phone: "11111111111",
      is_active: true,
      role: "superadmin"
    }

    with {:ok, business} <- create_business(business),
         {:ok, employee} <- {:ok, Map.put(employee, :business_id, business.id)},
         {:ok, employee} <- Store.create_employee(employee),
         {:ok, _admin_employee} <- Employee.create(Map.put(admin, :business_id, business.id)),
         {:ok, _sent} <-
           Store.Mailer.deliver(Store.EmployeeEmail.new_business_welcome_email(email, subdomain)) do
      {:ok, employee}
    else
      err -> err
    end
  end

  def get_businesses(options) do
    Business.get_all(options)
  end

  def get_sms_settings(location_id) do
    SMSSetting.get_by_location(location_id)
  end

  def save_sms_settings(settings) do
    SMSSetting.create(settings)
  end

  def in_roles?(admin_employee, roles) when is_list(roles) do
    Enum.member?(roles, admin_employee.role)
  end

  def in_role?(admin_employee, role) when is_binary(role) do
    in_roles?(admin_employee, [role])
  end

  def generate_authorization_token(business_id) do
    {:ok, %{token: AuthorizationToken.generate_login_token(business_id)}}
  end

  def seed_data(business_id, location_id) do
    query = "SELECT simulate(#{business_id}, #{location_id});"
    Ecto.Adapters.SQL.query(Repo, query, [], timeout: 120_000)
  end

  def get_active_locations(business_id) do
    Location.get_active_by_business(business_id)
  end
end
