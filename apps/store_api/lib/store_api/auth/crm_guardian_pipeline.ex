defmodule CRM.AuthAccessPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :store_api,
    module: CRM.Guardian,
    error_handler: CRM.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer")
  # plug Guardian.Plug.EnsureAuthenticated
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
