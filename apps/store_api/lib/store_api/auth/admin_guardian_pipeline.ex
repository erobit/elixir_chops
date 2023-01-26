defmodule Admin.AuthAccessPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :store_api,
    module: Admin.Guardian,
    error_handler: Admin.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer")
  # plug Guardian.Plug.EnsureAuthenticated
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
