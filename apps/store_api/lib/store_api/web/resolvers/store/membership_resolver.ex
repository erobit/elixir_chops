defmodule StoreAPI.Resolvers.Membership do
  alias Store

  def tablet_is_member(%{subdomain: subdomain, tablet: tablet, phone: phone}, _) do
    case Store.tablet_is_member(subdomain, tablet, phone) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, _error} -> {:ok, %{success: false}}
    end
  end

  ######################################
  # Mobile client queries
  ######################################

  def memberships(_, %{context: %{customer: customer}}) do
    case Store.memberships(customer.id) do
      [] -> {:ok, []}
      {:error, error} -> {:error, "Cannot get memberships: #{error}"}
      [memberships | tail] -> {:ok, [memberships | tail]}
      {:ok, memberships} -> {:ok, memberships}
    end
  end

  ######################################
  # Mobile client mutations
  ######################################

  def join_shop(%{location_id: location_id}, %{context: %{customer: customer}}) do
    case Store.join_shop(customer.id, location_id, true, true) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  def leave_shop(%{location_id: location_id}, %{context: %{customer: customer}}) do
    case Store.leave_shop(customer.id, location_id) do
      {:ok, _member} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end

  def set_location_notifications(
        %{location_id: location_id, is_enabled: is_enabled},
        %{context: %{customer: customer}}
      ) do
    case Store.set_location_notifications(customer.id, location_id, is_enabled) do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, error} -> {:error, error}
    end
  end
end
