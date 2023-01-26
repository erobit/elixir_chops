# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :store_api,
  namespace: StoreAPI

# Config set to empty repos
config :store_api, ecto_repos: []

# Configures the endpoint
config :store_api, StoreAPI.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "S2c6lqodlwLyn1Li5BK/wbwjKQ0woIDR+/MjqCKCP+55JglSAOL3M/uYThyAchK7",
  render_errors: [view: StoreAPI.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: StoreAPI.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :store_api, Admin.Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "AcmeAPI",
  ttl: { 1, :days },
  verify_issuer: true, # optional
  secret_key: "${ADMIN_GUARDIAN}" || "lond4OTfiyuVpX3h/dPa68fszanEdf3ZZDHtvfQqr4t6RL5NX/QoBKJLc7+g0qRy"

config :store_api, CRM.Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "AcmeAPI",
  ttl: { 90, :days },
  verify_issuer: true, # optional
  secret_key: "${CRM_GUARDIAN}" || "lond4OTfiyuVpX3h/dPa68fszanEdf3ZZDHtvfQqr4t6RL5NX/QoBKJLc7+g0qRy"

config :store_api, Mobile.Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "AcmeAPI",
  ttl: { 365, :days },
  verify_issuer: true, # optional
  secret_key: "${MOBILE_GUARDIAN}" || "lond4OTfiyuVpX3h/dPa68fszanEdf3ZZDHtvfQqr4t6RL5NX/QoBKJLc7+g0qRy"

config :store_api, Old.CRM.Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "AcmeAPI",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: "${OLD_GUARDIAN}" || "lond4OTfiyuVpX3h/dPa68fszanEdf3ZZDHtvfQqr4t6RL5NX/QoBKJLc7+g0qRy"

config :store_api, Old.Mobile.Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "AcmeAPI",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  secret_key: "${OLD_GUARDIAN}" || "lond4OTfiyuVpX3h/dPa68fszanEdf3ZZDHtvfQqr4t6RL5NX/QoBKJLc7+g0qRy"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
