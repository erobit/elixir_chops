defmodule Mobile.AuthAccessPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :store_api,
    module: Mobile.Guardian,
    error_handler: Mobile.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, claims: @claims, realm: "Bearer")
  # plug Guardian.Plug.EnsureAuthenticated
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
