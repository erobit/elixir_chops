defmodule StoreAPI.Resolvers.Business do
  alias Store
  alias StoreAdmin

  def get(_parent, _args, %{context: %{employee: employee}}) do
    case Store.get_business(employee.business_id) do
      nil -> {:error, "Business id #{employee.business_id} not found"}
      business -> {:ok, business}
    end
  end

  def get(%{id: id}, %{context: %{admin_employee: _admin}}) do
    case Store.get_business(id) do
      nil -> {:error, "Business id #{id} not found"}
      business -> {:ok, business}
    end
  end

  def get_all(options \\ %{options: %{page: %{offset: 0, limit: 0}}}, %{
        context: %{admin_employee: _admin}
      }) do
    StoreAdmin.get_businesses(options)
  end

  ## Admin business resolver functions

  def toggle_active(%{id: id, is_active: is_active}, %{context: %{admin_employee: admin_employee}}) do
    if StoreAdmin.in_roles?(admin_employee, ["sales", "admin", "super"]) do
      Store.toggle_active(Store.Business, id, is_active)
    else
      {:error, "Insufficient privileges to toggle business"}
    end
  end

  def save(business, %{context: %{admin_employee: admin_employee}}) do
    if StoreAdmin.in_roles?(admin_employee, ["sales", "admin", "super"]) do
      StoreAdmin.create_business(business)
    else
      {:error, "Insufficient privileges to create business"}
    end
  end
end
