defmodule StoreAPI.Resolvers.Reward do
  alias Store

  def create(deal, %{context: %{employee: employee}}) do
    reward = Map.put(deal, :business_id, employee.business_id)

    case Store.Loyalty.create_reward(reward) do
      {:error, changeset} -> {:error, inspect(changeset.errors)}
      {:ok, reward} -> {:ok, reward}
    end
  end

  def get_rewards(_parent, _, %{context: %{employee: employee}}) do
    location_ids =
      employee.locations
      |> Enum.filter(fn l -> l.is_active end)
      |> Enum.map(fn l -> l.id end)

    case Store.Loyalty.get_rewards(employee.business_id, location_ids) do
      [] -> {:error, "No rewards returned for Business #{employee.business_id}"}
      {:error, error} -> {:error, "Cannot get Rewards: #{error}"}
      [rewards | tail] -> {:ok, [rewards | tail]}
    end
  end

  def shop_opt(%{subdomain: subdomain, tablet: tablet}, _) do
    case Store.shop_opt(subdomain, tablet) do
      {:ok, shop_opt} -> {:ok, shop_opt}
      {:error, error} -> {:error, error}
    end
  end

  def toggle_active(%{id: id, is_active: is_active}, %{context: %{employee: _}}) do
    Store.toggle_active(Store.Reward, id, is_active)
  end

  #### Mobile client

  def queue(%{reward_id: reward_id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.queue_reward(customer.id, reward_id) do
      {:ok, customer_reward} -> {:ok, customer_reward}
      {:error, error} -> {:error, error}
    end
  end

  def get_recommended_rewards(options, %{context: %{customer: customer}}) do
    Store.get_recommended_rewards(customer.id, options)
  end

  def get_location_loyalty_reward(%{location_id: location_id}, %{context: %{customer: _}}) do
    Store.get_location_loyalty_reward(location_id)
  end
end
