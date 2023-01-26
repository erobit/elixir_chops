defmodule StoreAPI.Resolvers.Coupon do
  alias Store

  def redeem_deal(%{deal_id: deal_id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.redeem_coupon(Store.Loyalty.CustomerDeal, customer.id, deal_id) do
      {:error, error} -> {:error, error}
      {:ok, _} -> {:ok, %{success: true}}
    end
  end

  def redeem_reward(%{reward_id: reward_id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.redeem_coupon(Store.Loyalty.CustomerReward, customer.id, reward_id) do
      {:error, error} -> {:error, error}
      {:ok, _} -> {:ok, %{success: true}}
    end
  end

  def history(options, %{context: %{customer: customer}}) do
    case Store.Loyalty.coupon_history(customer.id, options) do
      {:error, _} -> {:error, "Cannot get coupon history"}
      {:ok, coupons} -> {:ok, coupons}
    end
  end
end
