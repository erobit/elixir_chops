defmodule StoreAPI.Resolvers.Location do
  alias Store

  def create(location, %{context: %{employee: employee}}) do
    location = Map.put(location, :business_id, employee.business_id)

    result = Store.create_store(location)
    case result do
      {:error, error} -> {:error, error}
      {:ok, location} -> {:ok, location}
    end
  end

  def get_location(_parent, %{id: id}, %{context: %{employee: employee}}) do
    case Store.get_location(id, employee.business_id) do
      nil -> {:error, "Location #{id} does not exist"}
      {:error, error} -> {:error, "Cannot get Location: #{error}"}
      location -> {:ok, location}
    end
  end

  def get_locations(_parent, options \\ %{options: %{page: %{offset: 0, limit: 0}}}, %{
        context: %{employee: employee}
      }) do
    if Store.in_roles?(employee, ["superadmin", "owner"]) do
      case Store.get_locations(employee.business_id, options) do
        [] -> {:ok, []}
        {:error, error} -> {:error, "Cannot get Locations: #{error}"}
        [locations | tail] -> {:ok, [locations | tail]}
        {:ok, locations} -> {:ok, locations}
      end
    else
      if Store.in_role?(employee, "manager") do
        location_ids = employee.locations |> Enum.map(fn l -> l.id end)
        Store.get_locations(employee.business_id, location_ids, options)
      else
        {:error, "Unauthorized"}
      end
    end
  end

  def get_locations_by_no_product_count(_, %{context: %{employee: employee}}) do
    case Store.get_locations_by_no_product_count(employee) do
      [] -> {:ok, []}
      [locations | tail] -> {:ok, [locations | tail]}
    end
  end

  def get_locations_for_employee(_, %{context: %{employee: employee}}) do
    case Store.get_locations_for_employee(employee) do
      [] -> {:ok, []}
      [locations | tail] -> {:ok, [locations | tail]}
    end
  end

  def get_locations_by_business(%{business_id: business_id}, %{context: %{admin_employee: admin}}) do
    if StoreAdmin.in_role?(admin, "super") do
      case Store.get_locations(business_id, nil) do
        [] -> {:ok, []}
        {:error, error} -> {:error, "Cannot get Locations: #{error}"}
        [locations | tail] -> {:ok, [locations | tail]}
        {:ok, locations} -> {:ok, locations}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def get_active_locations_by_business(%{business_id: business_id}, %{
        context: %{admin_employee: admin}
      }) do
    if StoreAdmin.in_role?(admin, "super") do
      case StoreAdmin.get_active_locations(business_id) do
        [] -> {:ok, []}
        {:error, error} -> {:error, "Cannot get Locations: #{error}"}
        [locations | tail] -> {:ok, [locations | tail]}
        {:ok, locations} -> {:ok, locations}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def toggle_active(%{id: id, is_active: is_active}, %{context: %{employee: _}}) do
    Store.toggle_active(Store.Location, id, is_active)
  end

  def get_qr_code(%{location_id: location_id}, %{context: %{employee: _}}) do
    case Store.get_qr_code(location_id) do
      {:ok, qr_code} -> {:ok, qr_code}
      {:error, error} -> {:error, "Cannot get uuid: #{error}"}
    end
  end

  def set_qr_code(%{location_id: location_id}, %{context: %{employee: _}}) do
    case Store.set_qr_code(location_id) do
      {:ok, qr_code} -> {:ok, qr_code}
      {:error, error} -> {:error, "Cannot get uuid: #{error}"}
    end
  end

  def tablets(%{subdomain: subdomain}, _) do
    case Store.location_tablets(subdomain) do
      {:ok, tablets} -> {:ok, tablets}
      {:error, error} -> {:error, "Tablets not found: #{error}"}
    end
  end

  ######################################
  # mobile client location Resolvers
  ######################################

  def discover_locations(options \\ %{options: %{page: %{offset: 0, limit: 0}}}, %{
        context: %{customer: customer}
      }) do
    case Store.discover_locations(customer.id, options) do
      [] -> {:error, "No locations returned for Business #{customer.id}"}
      {:error, error} -> {:error, "Cannot get Locations: #{error}"}
      [locations | tail] -> {:ok, [locations | tail]}
      {:ok, locations} -> {:ok, locations}
    end
  end

  def get_store_page(%{id: id}, %{context: %{customer: customer}}) do
    case Store.get_store_page(customer.id, id) do
      {:error, error} -> {:error, "Cannot get Location: #{error}"}
      {:ok, location} -> {:ok, location}
    end
  end
end
