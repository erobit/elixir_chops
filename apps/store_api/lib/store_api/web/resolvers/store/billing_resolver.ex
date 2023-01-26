defmodule StoreAPI.Resolvers.Billing do
  alias Store.Billing

  def get_trial_periods(_empty, %{context: %{employee: employee}}) do
    is_role_member = Store.in_roles?(employee, ["superadmin", "owner", "manager"])

    if is_role_member do
      case Billing.trial_periods(employee.business_id) do
        {:ok, trials} -> {:ok, trials}
        {:error, error} -> {:ok, error}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def get_profile(%{location_id: location_id}, %{context: %{employee: employee}}) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)
    is_role_member = Store.in_roles?(employee, ["superadmin", "owner", "manager"])

    if is_location_member and is_role_member do
      with {:ok, profile} <- Billing.get_profile(location_id),
           {:ok, cards} <- Billing.get_cards(location_id) do
        {:ok, Map.put(profile, :cards, cards)}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def update_profile(profile, %{context: %{employee: employee}}) do
    is_location_member = Store.employee_member_of_location?(employee, profile.location_id)
    is_role_member = Store.in_roles?(employee, ["superadmin"])

    if is_location_member and is_role_member do
      case Billing.update_profile(profile) do
        {:ok, profile} -> {:ok, profile}
        {:error, error} -> {:error, error}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def create_card(%{location_id: location_id, token: single_use_token}, %{
        context: %{employee: employee}
      }) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)
    is_role_member = Store.in_roles?(employee, ["superadmin", "owner", "manager"])

    if is_location_member and is_role_member do
      case Billing.create_card(location_id, single_use_token) do
        {:ok, card} -> {:ok, %{id: card.id, success: true}}
        {:error, error} -> {:error, error.code}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def update_card(card, %{context: %{employee: employee}}) do
    is_location_member = Store.employee_member_of_location?(employee, card.location_id)
    is_role_member = Store.in_roles?(employee, ["superadmin", "owner", "manager"])

    if is_location_member and is_role_member do
      case Billing.update_card(card.id, card.expiry_month, card.expiry_year) do
        {:ok, card} -> {:ok, card}
        {:error, error} -> {:error, error.code}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def in_good_standing(%{location_id: location_id}, %{context: %{employee: employee}}) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)

    if is_location_member do
      case Billing.in_good_standing?(location_id) do
        true -> {:ok, %{success: true}}
        false -> {:ok, %{success: false}}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def get_card(%{id: id, location_id: location_id}, %{context: %{employee: employee}}) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)
    is_role_member = Store.in_roles?(employee, ["superadmin", "owner", "manager"])

    if is_location_member and is_role_member do
      case Billing.get_card(id) do
        {:ok, card} -> {:ok, card}
        {:error, error} -> {:ok, error}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def delete_card(%{id: id, location_id: location_id}, %{context: %{employee: employee}}) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)
    is_role_member = Store.in_roles?(employee, ["superadmin", "owner", "manager"])

    if is_location_member and is_role_member do
      case Billing.delete_card(id) do
        {:ok, card} -> {:ok, %{success: true, id: card.id}}
        {:error, _error} -> {:ok, %{success: false}}
      end
    else
      {:error, "Unauthorized"}
    end
  end

  def set_default_card(%{id: id, location_id: location_id}, %{context: %{employee: employee}}) do
    is_location_member = Store.employee_member_of_location?(employee, location_id)
    is_role_member = Store.in_roles?(employee, ["superadmin", "owner", "manager"])

    if is_location_member and is_role_member do
      case Billing.set_default_card(id) do
        {:ok, card} -> {:ok, %{success: true, id: card.id}}
        {:error, _error} -> {:ok, %{success: false}}
      end
    else
      {:error, "Unauthorized"}
    end
  end
end
