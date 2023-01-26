defmodule StoreAPI.Resolvers.Referral do
  alias Store

  def link(%{location_id: location_id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.create_referral_link(customer.id, location_id) do
      {:ok, link} -> {:ok, link}
      {:error, error} -> {:error, error}
    end
  end

  def latest(_, %{context: %{customer: customer}}) do
    case Store.latest_referral(customer.id) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, error}
    end
  end

  def create(%{phone: phone, code: code}, %{context: %{employee: _}}) do
    case Store.create_referral(phone, code) do
      {:ok, referral} -> {:ok, referral}
      {:error, error} -> {:error, error}
    end
  end

  def shop(%{code: code}, %{context: %{employee: _}}) do
    case Store.Loyalty.get_shop(code) do
      {:ok, shop} -> {:ok, shop}
      {:error, error} -> {:error, error}
    end
  end

  def shop_intent(%{code: code}, %{context: %{customer: _}}) do
    case Store.Loyalty.get_shop_from_intent(code) do
      {:ok, location_id} -> {:ok, %{location_id: Enum.at(location_id, 0)}}
      {:error, error} -> {:error, error}
    end
  end
end
