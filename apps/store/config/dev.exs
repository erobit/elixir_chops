use Mix.Config

config :logger, level: :debug

config :store, Store.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  types: Store.PostgresTypes,
  log: :debug

config :store, :environment, :dev

config :store, Store.Mailer,
  adapter: Swoosh.Adapters.Local,
  prefix: "http://",
  path: "localhost:3000/reset/",
  from: "donotreply@domain.com",
  feedback: System.get_env("FEEDBACK_EMAIL")

config :store, Store.Referrer,
  prefix: "http://",
  path: "localhost:3000/r/"

config :store, Store.Surveyor,
  prefix: "http://",
  path: "localhost:3000/s/"

config :store, :twilio,
  auth_id: System.get_env("TWILIO_AUTH_ID"),
  auth_token: System.get_env("TWILIO_AUTH_TOKEN"),
  msg_campaign_sid: System.get_env("TWILIO_MESSAGING_SERVICE_SID")

config :store, :paysafe,
  endpoint: System.get_env("PAYSAFE_API_ENDPOINT"),
  username: System.get_env("PAYSAFE_USERNAME"),
  password: System.get_env("PAYSAFE_PASSWORD"),
  account_id: System.get_env("PAYSAFE_ACCOUNT_ID")

config :store, :geocoder, Store.Geo.Geocode

config :store, Encryption.AES,
  key: "adflkjadfkhasdfkh12312341234123d-809uiuodasf"