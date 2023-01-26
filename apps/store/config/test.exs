use Mix.Config

config :store, Store.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool: Ecto.Adapters.SQL.Sandbox,
  types: Store.PostgresTypes,
  log: false

config :store, :environment, :test

config :store, Store.Mailer,
  adapter: Swoosh.Adapters.Test,
  prefix: "http://",
  path: "localhost:3000/reset/",
  from: "donotreply@domain.com",
  feedback: System.get_env("FEEDBACK_EMAIL")

config :store, Store.Referrer,
  prefix: "http://",
  path: "domain.com/r/"

config :store, Store.Surveyor,
  prefix: "http://",
  path: "domain.com/s/"

config :store, :geocoder, Store.Geo.GeocodeFake

# only to be used in test
# config :bcrypt_elixir, log_rounds: 4