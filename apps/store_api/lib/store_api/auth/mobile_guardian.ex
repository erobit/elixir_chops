defmodule Mobile.Guardian do
  use Guardian, otp_app: :store_api
  use Store.Model

  def subject_for_token(customer = %Customer{}, _claims) do
    token = %{
      "cid" => customer.id,
      "v" => "1.0"
      # Do we need to add other information here?????
      # country, phone, email, etc???
    }

    {:ok, Poison.encode!(token)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    token = Poison.decode!(claims["sub"])
    {:ok, Store.get_customer(token["cid"])}
  end
end
