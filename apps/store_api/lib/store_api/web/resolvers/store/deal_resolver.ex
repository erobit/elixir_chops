defmodule StoreAPI.Resolvers.Deal do
  alias Store

  def create(deal, %{context: %{employee: employee}}) do
    deal = Map.put(deal, :business_id, employee.business_id)

    case Store.Loyalty.create_deal(deal) do
      {:error, changeset} -> {:error, inspect(changeset.errors)}
      {:ok, deal} -> {:ok, deal}
    end
  end

  def get_deal(%{id: id}, %{context: %{employee: _employee}}) do
    case Store.Loyalty.get_deal(id) do
      {:error, error} -> {:error, "Cannot get deal: #{error}"}
      deal -> {:ok, deal}
    end
  end

  def get_deals(_parent, %{options: options, location_id: location_id}, %{
        context: %{employee: employee}
      }) do
    location_ids = employee.locations |> Enum.map(fn l -> l.id end)

    case Enum.member?(location_ids, location_id) do
      true ->
        case Store.Loyalty.get_deals(employee.business_id, location_id, %{options: options}) do
          [] -> {:error, "No deals returned for Business #{employee.business_id}"}
          {:error, error} -> {:error, "Cannot get Deals: #{error}"}
          {:ok, employees} -> {:ok, employees}
        end

      false ->
        {:error, "Forbidden"}
    end
  end

  def toggle_active(%{id: id, is_active: is_active}, %{context: %{employee: _}}) do
    Store.toggle_active(Store.Loyalty.Deal, id, is_active)
  end

  ### Mobile client

  def queue(%{deal_id: deal_id, location_id: location_id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.queue_deal(customer.id, deal_id, location_id) do
      {:ok, customer_deal} -> {:ok, customer_deal}
      {:error, error} -> {:error, error}
      customer_deal -> {:ok, customer_deal}
    end
  end
end
