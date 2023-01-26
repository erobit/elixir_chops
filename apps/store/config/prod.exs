use Mix.Config

config :logger, level: :info

config :store, Store.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  types: Store.PostgresTypes,
  ssl: true,
  ssl_opts: [
    cacertfile: System.get_env("PG_SSL_CERT") || "/home/ubuntu/ssl/rds-ca-2015-root.pem"
  ],
  log: false

config :store, :environment, :prod

config :store, Store.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  prefix: "https://",
  path: "domain.com/reset/",
  path_admin: "domain.com/reset/",
  from: "donotreply@domain.com",
  domain: "domain.com",
  feedback: System.get_env("FEEDBACK_EMAIL") ,
  relay: System.get_env("SMTP_RELAY"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  ssl: false,
  auth: :always,
  port: 587,
  retries: 2,
  no_mx_lookups: true

config :store, Store.NewBusinessMailer,
  prefix: "https://",
  path: "domain.com",
  from: "donotreply@domain.com",
  relay: System.get_env("SMTP_RELAY"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  ssl: false,
  auth: :always,
  port: 587,
  retries: 2,
  no_mx_lookups: true

config :store, Store.Referrer,
  prefix: "https://",
  path: "domain.com/r/"

config :store, Store.Surveyor,
  prefix: "https://",
  path: "domain.com/s/"

config :store, :geocoder, Store.Geo.Geocode

# Import Timber, structured logging
import_config "timber.exs"
