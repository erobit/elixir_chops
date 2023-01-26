defmodule StoreAPI.Resolvers.Inventory do
  alias Store

  def get_categories(_parent, %{context: %{employee: _employee}}) do
    case Store.Inventory.get_categories() do
      nil -> {:error, "No categories returned"}
      {:error, error} -> {:error, "Cannot get categories: #{error}"}
      categories -> {:ok, categories}
    end
  end

  def get_product(%{id: id}, %{context: %{employee: _}}) do
    Store.Inventory.get_product(id)
  end

  def get_product(%{id: id}, %{context: %{customer: customer}}) do
    Store.Inventory.get_product_for_customer(id, customer.id)
  end

  def get_products(%{location_id: location_id, options: options}, %{
        context: %{employee: _employee}
      }) do
    Store.Inventory.get_products(location_id, %{options: options})
  end

  def product_count(%{location_id: location_id}, %{context: %{employee: _employee}}) do
    Store.Inventory.product_count(location_id)
  end

  def get_products_paged(args, %{context: %{customer: customer}}) do
    Store.Inventory.get_products_paged(Map.get(args, :location_id), customer.id, args.options)
  end

  def get_products_by_location_in_stock(%{location_id: location_id}, %{context: %{customer: _}}) do
    Store.Inventory.get_products_by_location_in_stock(location_id)
  end

  def save_product(product, %{context: %{employee: _employee}}) do
    Store.Inventory.save_product(product)
  end

  def toggle_product(%{id: id}, %{context: %{employee: _employee}}) do
    Store.Inventory.toggle_product(id)
  end

  def toggle_product_stock(%{id: id}, %{context: %{employee: _employee}}) do
    Store.Inventory.toggle_product_stock(id)
  end

  def get_pricing_preference(%{location_id: location_id}, %{context: %{customer: _}}) do
    Store.Inventory.get_pricing_preference(%{location_id: location_id})
  end

  def get_pricing_preference(%{location_id: location_id}, %{context: %{employee: _}}) do
    Store.Inventory.get_pricing_preference(%{location_id: location_id})
  end

  def set_pricing_preference(%{is_basic: is_basic, location_id: location_id}, %{
        context: %{employee: _}
      }) do
    Store.Inventory.set_pricing_preference(location_id, is_basic)
  end

  def get_pricing_tiers(%{location_id: location_id}, %{context: %{employee: _employee}}) do
    Store.Inventory.get_pricing_tiers(location_id)
  end

  def save_pricing_tier(tier, %{context: %{employee: _employee}}) do
    Store.Inventory.save_pricing_tier(tier)
  end

  def remove_pricing_tier(args, %{context: %{employee: _employee}}) do
    Store.Inventory.remove_pricing_tier(args)
  end

  def get_quick_glance_menu(%{location_id: location_id}, %{context: %{customer: customer}}) do
    case Store.Inventory.quick_glance_menu(location_id, customer.id) do
      {:error, error} -> {:error, error}
      {:ok, menu} -> {:ok, menu}
    end
  end

  def get_product_integration(%{location_id: location_id}, %{context: %{employee: employee}}) do
    with {:ok, true} <- Store.Employee.can_access_location?(employee.id, location_id) do
      Store.Inventory.Integration.get_product_integration(location_id)
    else
      _err -> {:error, "No product integration"}
    end
  end

  def set_product_integration(integration, %{context: %{employee: employee}}) do
    integration = Map.drop(integration, [:id])

    with {:ok, true} <- Store.Employee.can_access_location?(employee.id, integration.location_id) do
      case integration.is_active do
        true ->
          with {:ok, _} <-
                 Store.Inventory.Integration.remove_product_integration(integration.location_id),
               {:ok, _} <- Store.Inventory.Integration.set_product_integration(integration),
               {:ok, _} <-
                 Store.Inventory.PricingPreference.toggle_business_preference(
                   integration.location_id,
                   true
                 ),
               {:ok, _} <- Store.Inventory.Integration.sync_items(integration.location_id) do
            {:ok, %{success: true}}
          else
            err -> err
          end

        false ->
          case Store.Inventory.Integration.remove_product_integration(integration.location_id) do
            {:ok, _res} -> {:ok, %{success: true}}
            {:error, _err} -> {:error, "Could not remove product integration"}
          end
      end
    else
      _err -> {:error, "Could not set product integration"}
    end
  end

  def refresh_product_integration(%{location_id: location_id}, %{context: %{employee: employee}}) do
    with {:ok, true} <- Store.Employee.can_access_location?(employee.id, location_id),
         {:ok, _} <- Store.Inventory.Integration.sync_items(location_id) do
      {:ok, %{success: true}}
    else
      _err -> {:error, "Could not refresh product integration"}
    end
  end

  def validate_product_integration(args, %{
        context: %{employee: _employee}
      }) do
    case Store.Inventory.Integration.validate_product_integration(args) do
      {:error, error} -> {:error, error}
      {:ok, result} -> {:ok, result}
    end
  end

  def get_product_sync_items(%{location_id: location_id, options: options}, %{
        context: %{employee: employee}
      }) do
    with {:ok, true} <- Store.Employee.can_access_location?(employee.id, location_id) do
      case Store.Inventory.Integration.get_product_sync_items(location_id, %{options: options}) do
        {:error, error} -> {:error, error}
        {:ok, items} -> {:ok, items}
      end
    else
      _err -> {:error, "Cannot get product sync items"}
    end
  end

  def save_product_sync_item(sync_item, %{context: %{employee: employee}}) do
    with {:ok, true} <- Store.Employee.can_access_location?(employee.id, sync_item.location_id) do
      case Store.Inventory.Integration.save_product_sync_item(sync_item) do
        {:error, error} -> {:error, error}
        {:ok, _item} -> {:ok, %{success: true}}
      end
    else
      _err -> {:error, "Cannot save sync item"}
    end
  end

  def toggle_favourite_product(%{is_active: is_active, product_id: product_id}, %{
        context: %{customer: customer}
      }) do
    Store.Inventory.toggle_favourite_product(is_active, product_id, customer.id)
  end

  def get_favourite_products(_, %{context: %{customer: customer}}) do
    Store.Inventory.get_customer_favourite_products(customer.id)
  end

  def product_import(%{location_id: location_id, products: products}, %{
        context: %{employee: employee}
      }) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)

    if is_location_member do
      try do
        products =
          File.stream!(products.path)
          |> CSV.decode!(headers: true)
          |> Enum.with_index()

        Store.Inventory.product_import(location_id, products)
      rescue
        e ->
          {:error, Map.get(e, :message, "Invalid CSV file")}
      end
    else
      {:error, "Unauthorized"}
    end
  end
end
