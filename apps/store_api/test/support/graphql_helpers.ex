defmodule StoreAPI.Web.GraphqlHelpers do
  import Store.Factory
  use ExMachina
  use Phoenix.ConnTest

  {:ok, _} = Application.ensure_all_started(:ex_machina)

  @valid_employee params_for(:employee)
  @valid_business params_for(:business)

  def get_conn(:unauthorized), do: build_conn()

  def get_conn(:authorized) do
    {:ok, business} = StoreAdmin.create_business(@valid_business)
    {:ok, employee} = create_employee(business)
    employee = Store.get_employee(employee.id)
    {:ok, jwt, _} = CRM.Guardian.encode_and_sign(employee, token_type: :access)

    build_conn()
    |> put_req_header("employee_id", "#{employee.id}")
    |> put_req_header("business_id", "#{business.id}")
    |> put_req_header("authorization", "Bearer #{jwt}")
    |> put_req_header("content-type", "application/json")
    |> put_req_header("origin", "http://#{business.subdomain}.localhost")
  end

  def get_conn(:admin_authorized) do
    {:ok, business} = StoreAdmin.create_business(@valid_business)
    {:ok, employee} = create_admin_employee(business)
    employee = StoreAdmin.get_employee(employee.id)
    {:ok, jwt, _} = Admin.Guardian.encode_and_sign(employee, token_type: :access)

    build_conn()
    |> put_req_header("employee_id", "#{employee.id}")
    |> put_req_header("business_id", "#{business.id}")
    |> put_req_header("authorization", "Bearer #{jwt}")
    |> put_req_header("content-type", "application/json")
    |> put_req_header("origin", "http://#{business.subdomain}.localhost")
  end

  # @TODO - replace this with the convenience Store.sign_up method in the future
  defp create_employee(business) do
    @valid_employee
    |> Map.put(:business_id, business.id)
    |> Map.put(:email, sequence(:email, &"email-#{&1}@example.com"))
    |> Store.create_employee()
  end

  defp create_admin_employee(business) do
    @valid_employee
    |> Map.put(:business_id, business.id)
    |> Map.put(:name, "Super Tester")
    |> Map.put(:phone, "12222223333")
    |> Map.put(:role, "super")
    |> Map.put(:password, "super123")
    |> Map.put(:email, sequence(:email, &"email-#{&1}@example.com"))
    |> StoreAdmin.create_employee(business.subdomain)
  end

  def query_skeleton(query, query_name) do
    query_skeleton(query, query_name, "{}")
  end

  def query_skeleton(query, query_name, variables) do
    %{
      "operationName" => "#{query_name}",
      "query" => "query #{query_name} #{query}",
      "variables" => variables
    }
  end

  def query_raw(query, variables) do
    %{
      "query" => "#{query}",
      "variables" => variables
    }
  end

  def mutate_skeleton(query, query_name) do
    %{
      "operationName" => "#{query_name}",
      "query" => "mutation #{query_name} #{query}",
      "variables" => "{}"
    }
  end
end
