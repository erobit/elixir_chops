defmodule StoreAPI.Resolvers.Token do
  def refresh_employee(%{token: token}, _) do
    case Old.CRM.Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        employee = Poison.decode!(claims["sub"])

        if Map.has_key?(employee, "v") do
          {:error, "invalid token"}
        else
          employee = Store.get_employee(employee["uid"])

          case CRM.Guardian.encode_and_sign(employee, %{}, token_type: :access) do
            {:ok, jwt, _} -> {:ok, %{token: jwt}}
            {:error, error} -> {:error, error}
          end
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def refresh_customer(%{token: token}, _) do
    case Old.Mobile.Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        customer = Poison.decode!(claims["sub"])

        if Map.has_key?(customer, "v") do
          {:error, "invalid token"}
        else
          {:ok, customer} = Store.get_customer_sanitized(customer["cid"])

          case Mobile.Guardian.encode_and_sign(customer, token_type: :access) do
            {:ok, jwt, _} -> {:ok, %{token: jwt}}
            {:error, error} -> {:error, error}
          end
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
