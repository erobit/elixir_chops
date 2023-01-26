defmodule StoreAPI.Resolvers.CustomerReward do
  alias Store

  def get(%{id: id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.get_customer_reward(customer.id, id) do
      nil -> {:error, "Cannot find customer reward"}
      customer_reward -> {:ok, customer_reward}
    end
  end

  def queue(%{reward_id: reward_id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.queue_customer_reward(customer.id, reward_id) do
      {:ok, reward} -> {:ok, reward}
      {:error, error} -> {:error, error}
    end
  end
end
