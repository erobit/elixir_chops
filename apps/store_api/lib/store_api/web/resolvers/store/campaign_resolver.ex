defmodule StoreAPI.Resolvers.Campaign do
  alias Store

  def create(campaign, %{context: %{employee: employee}}) do
    campaign = Map.put(campaign, :business_id, employee.business_id)

    location_ids = employee.locations |> Enum.map(fn l -> l.id end)

    case Enum.member?(location_ids, campaign.location_id) do
      true ->
        case Store.create_campaign(campaign) do
          {:error, error} -> {:error, error}
          {:ok, campaign} -> {:ok, campaign}
        end

      false ->
        {:error, "Forbidden"}
    end
  end

  def customer_count(campaign, %{context: %{employee: employee}}) do
    campaign = Map.put(campaign, :business_id, employee.business_id)

    case Store.campaign_customer_count(campaign) do
      {:error, error} -> {:error, error}
      count -> {:ok, %{id: count}}
    end
  end

  def get_campaign(%{id: id}, %{context: %{employee: employee}}) do
    case Store.get_campaign(employee.business_id, id) do
      {:error, error} -> {:error, "Cannot get campaign: #{error}"}
      {:ok, campaign} -> {:ok, campaign}
    end
  end

  def cancel(%{id: id}, %{context: %{employee: employee}}) do
    case Store.cancel_campaign(employee.business_id, id) do
      {:error, error} -> {:error, "Cannot cancel campaign: #{error}"}
      {:ok, campaign} -> {:ok, campaign}
    end
  end

  def get_campaigns(_parent, %{location_id: location_id, options: options}, %{
        context: %{employee: employee}
      }) do
    location_ids =
      employee.locations
      |> Enum.filter(fn l -> l.is_active end)
      |> Enum.map(fn l -> l.id end)

    case Enum.member?(location_ids, location_id) do
      true ->
        case Store.get_campaigns(employee.business_id, location_id, %{options: options}) do
          [] -> {:error, "No campaigns returned for Business #{employee.business_id}"}
          {:error, error} -> {:error, "Cannot get Campaigns: #{error}"}
          {:ok, campaigns} -> {:ok, campaigns}
        end

      false ->
        {:error, "Forbidden"}
    end
  end

  def get_campaign_reports(%{campaign_id: campaign_id, options: options}, %{
        context: %{employee: employee}
      }) do
    Store.get_campaign_reports(employee.business_id, campaign_id, options)
  end

  def toggle_active(%{id: id, is_active: is_active}, %{context: %{employee: _}}) do
    Store.toggle_active(Store.Campaign, id, is_active)
  end

  def click(%{code: code}, %{context: %{customer: _customer}}) do
    Store.log_campaign_click(code)
  end

  def send_stats(%{location_id: location_id, number_to_send: number_to_send}, %{
        context: %{employee: _employee}
      }) do
    case Store.campaign_send_stats(location_id, number_to_send) do
      {:ok, stats} -> {:ok, stats}
      {:error, _error} -> {:error, "No stats available for business_id"}
    end
  end

  def sms_test(%{location_id: location_id, message: message, phones: phones}, %{
        context: %{employee: _employee}
      }) do
    case Store.sms_test(location_id, message, phones) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  def disable_sms_notifications_for_campaign_error_code(
        %{campaign_id: campaign_id, location_id: location_id, error_code: error_code},
        %{context: %{employee: _employee}}
      ) do
    Store.disable_sms_notifications_for_campaign_error_code(
      location_id,
      campaign_id,
      error_code
    )
  end
end
