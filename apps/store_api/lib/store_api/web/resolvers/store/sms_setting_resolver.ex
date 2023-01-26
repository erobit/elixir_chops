defmodule StoreAPI.Resolvers.SMSSetting do
  alias Store
  alias StoreAdmin

  def get(%{location_id: location_id}, %{context: %{admin_employee: _admin_employee}}) do
    case StoreAdmin.get_sms_settings(location_id) do
      nil -> {:error, "SMS Setting for location_id #{location_id} not found"}
      settings -> {:ok, settings}
    end
  end

  def save(settings, %{context: %{admin_employee: _admin_employee}}) do
    case StoreAdmin.save_sms_settings(settings) do
      {:ok, settings} -> {:ok, settings}
      {:error, error} -> {:error, error}
    end
  end

  def get_tfn(_, %{context: %{employee: _employee}}) do
    case Store.Messaging.SMS.get_tfn() do
      {:ok, number} -> {:ok, %{number: number}}
      {:error, error} -> {:error, error}
    end
  end

  def check_tfn(%{phone: phone}, %{context: %{employee: employee}}) do
    case Store.Messaging.SMS.check_tfn(phone, employee.business_id) do
      {:ok, result} -> {:ok, %{success: result}}
      {:error, error} -> {:error, error}
    end
  end
end
