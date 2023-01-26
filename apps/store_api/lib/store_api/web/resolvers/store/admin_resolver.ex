defmodule StoreAPI.Resolvers.Admin do
  alias Store
  alias StoreAdmin
  alias Store.Utility.Security, as: Security

  def login(%{email: email, password: password}, _info) do
    with {:ok, employee} <- StoreAdmin.authenticate(email, password),
         {:ok, jwt, _} <- Admin.Guardian.encode_and_sign(employee, token_type: :access) do
      {:ok, %{token: jwt}}
    end
  end

  def password_strength(%{password: password}, _info) do
    Security.check_password_strength(password)
  end

  def employee_reset(%{email: email}, %{context: %{subdomain: subdomain}}) do
    case StoreAdmin.employee_reset(email, subdomain) do
      {:ok, reset} -> {:ok, %{email: reset.email}}
      {:error, error} -> {:error, error}
    end
  end

  def get_reset(%{id: id}, _info) do
    case StoreAdmin.get_employee_reset(id) do
      nil -> {:error, "reset not found"}
      _ -> {:ok, %{id: id}}
    end
  end

  def reset_password(%{id: id, password: password}, _info) do
    case StoreAdmin.set_employee_password(id, password) do
      {:ok, reset} -> {:ok, %{email: reset.email, strength: reset.strength}}
      {:error, error} -> {:error, error}
    end
  end

  def provision(
        %{
          email: email,
          phone: phone,
          name: name,
          subdomain: subdomain,
          language: language,
          type: type
        },
        %{context: %{admin_employee: _}}
      ) do
    case StoreAdmin.provision(email, phone, name, subdomain, type, language) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def generate_authorization_token(%{business_id: business_id}, %{
        context: %{admin_employee: admin_employee}
      }) do
    if StoreAdmin.in_role?(admin_employee, "super") do
      StoreAdmin.generate_authorization_token(business_id)
    else
      {:error, "Insufficient privileges to generate auth token"}
    end
  end

  def get_all(options, %{context: %{admin_employee: _}}) do
    StoreAdmin.get_all_admins(options)
  end

  def get_by_id(%{id: id}, %{context: %{admin_employee: _}}) do
    case StoreAdmin.get_employee(id) do
      nil -> {:error, "No employee found."}
      employee -> {:ok, employee}
    end
  end

  def save(new_admin, %{context: %{admin_employee: admin_employee}}) do
    if StoreAdmin.in_role?(admin_employee, "super") do
      StoreAdmin.create_employee(new_admin, "admin")
    else
      {:error, "Insufficient privileges to create employee"}
    end
  end

  def raw_push_notification(%{tokens: tokens, message: message, title: title, id: id}, %{
        context: %{admin_employee: admin}
      }) do
    if StoreAdmin.in_role?(admin, "super") do
      data =
        case id do
          nil ->
            nil

          _ ->
            case Poison.decode(id) do
              {:ok, obj} -> obj
              {:error, _} -> %{id: id}
            end
        end

      Store.fcm_raw_push(tokens, message, title, data)
    else
      {:error, "Insufficient priveleges"}
    end
  end

  def seed_data(%{business_id: business_id, location_id: location_id}, %{
        context: %{admin_employee: admin_employee}
      }) do
    env = System.get_env("ENV")

    if env == "prod" do
      {:error, "This cannot be run on production"}
    else
      if StoreAdmin.in_role?(admin_employee, "super") do
        StoreAdmin.seed_data(business_id, location_id)
      else
        {:error, "Insufficient privileges to seed data"}
      end
    end
  end
end
