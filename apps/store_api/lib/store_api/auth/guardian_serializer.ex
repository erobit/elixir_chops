defmodule StoreAPI.GuardianSerializer do
  # @behaviour Guardian.Serializer

  use Store.Model

  # CRM admin token serialization
  def for_token(user = %Employee{}) do
    token = %{
      "bid" => user.business_id,
      "uid" => user.id,
      "cc" => user.business.country,
      "sd" => user.business.subdomain
    }

    {:ok, Poison.encode!(token)}
  end

  # mobile client token serialization
  def for_token(customer = %Customer{}) do
    token = %{
      "cid" => customer.id
      # Do we need to add other information here?????
      # country, phone, email, etc???
    }

    {:ok, Poison.encode!(token)}
  end

  def for_token(_), do: {:error, "Unknown resource type"}

  # handles deserialization of token and branches out to handles
  # admin crm tokens as well as mobile client tokens based upon the fields
  # present in the token
  def from_token(token) when is_binary(token) do
    token = Poison.decode!(token)
    {:ok, get_entity(token)}
  end

  def from_token(_), do: {:error, "Unknown resource type"}

  defp get_entity(%{"uid" => id}) do
    Store.get_employee(id)
  end

  defp get_entity(%{"cid" => id}) do
    {:ok, customer} = Store.get_customer_sanitized(id)
    customer
  end

  defp get_entity(_), do: nil
end
