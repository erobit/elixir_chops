defmodule CRM.Guardian do
  use Guardian, otp_app: :store_api
  use Store.Model

  def subject_for_token(employee = %Employee{}, _claims) do
    token = %{
      "bid" => employee.business_id,
      "uid" => employee.id,
      "cc" => employee.business.country,
      "sd" => employee.business.subdomain,
      "v" => "1.0"
    }

    {:ok, Poison.encode!(token)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    token = Poison.decode!(claims["sub"])
    {:ok, Store.get_employee(token["uid"])}
  end
end
