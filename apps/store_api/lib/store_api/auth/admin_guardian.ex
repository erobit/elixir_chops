defmodule Admin.Guardian do
  use Guardian, otp_app: :store_api
  use Store.Model

  def subject_for_token(employee = %AdminEmployee{}, _claims) do
    token = %{
      "aid" => employee.id,
      "r" => employee.role,
      "v" => "1.0"
    }

    {:ok, Poison.encode!(token)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    token = Poison.decode!(claims["sub"])
    {:ok, StoreAdmin.get_employee(token["aid"])}
  end
end
