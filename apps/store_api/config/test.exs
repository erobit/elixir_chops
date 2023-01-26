use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :store_api, StoreAPI.Web.Endpoint,
  http: [port: 4001],
  server: false

config :store_api, :environment, :test

# only to be used in test
# config :bcrypt_elixir, log_rounds: 4

# Print only warnings and errors during test
# config :logger, level: :warn
