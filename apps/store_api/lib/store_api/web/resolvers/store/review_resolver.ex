defmodule StoreAPI.Resolvers.Review do
  alias Store

  def get_location_reviews(_parent, options \\ %{options: %{page: %{offset: 0, limit: 0}}}, %{
        context: %{employee: employee}
      }) do
    case Store.get_location_reviews(employee.business_id, [options.location_id], options) do
      {:error, error} -> {:error, "Cannot get location reviews: #{error}"}
      reviews_paged -> {:ok, reviews_paged}
    end
  end

  def get_location_reviews_for_customer(%{location_id: location_id}, %{
        context: %{customer: customer}
      }) do
    Store.get_location_reviews(location_id, customer.id)
  end

  def create_review(review, %{context: %{customer: customer}}) do
    case Store.create_review(review, customer) do
      {:ok, result} -> {:ok, result}
      {:error, error} -> {:error, "Error saving review: #{error}"}
    end
  end

  def get_customer_review(%{location_id: location_id}, %{context: %{customer: customer}}) do
    case Store.get_customer_review(customer.id, location_id) do
      {:error, error} -> {:error, error}
      result -> {:ok, result}
    end
  end
end
