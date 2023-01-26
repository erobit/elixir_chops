defmodule StoreAPI.Resolvers.Visit do
  alias Store

  def visit(%{lat: lat, lng: lng}, %{context: %{customer: customer}}) do
    case Store.visit(customer.id, lat, lng) do
      {:error, error} -> {:error, error}
      {:ok, result} -> {:ok, result}
    end
  end
end
