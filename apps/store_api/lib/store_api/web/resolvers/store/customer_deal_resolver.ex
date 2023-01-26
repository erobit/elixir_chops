defmodule StoreAPI.Resolvers.CustomerDeal do
  alias Store

  def get(%{id: id}, %{context: %{customer: customer}}) do
    case Store.Loyalty.get_customer_deal(customer.id, id) do
      nil -> {:error, "Cannot find customer deal"}
      customer_deal -> {:ok, customer_deal}
    end
  end
end
