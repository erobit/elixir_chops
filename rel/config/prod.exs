use Mix.Config

# store_api config
config :store_api, Admin.Guardian,
  secret_key: System.get_env("ADMIN_GUARDIAN")

config :store_api, CRM.Guardian,
  secret_key: System.get_env("CRM_GUARDIAN")

config :store_api, Mobile.Guardian,
  secret_key: System.get_env("MOBILE_GUARDIAN")

port = String.to_integer(System.get_env("PORT"))
host = System.get_env("HOST")
config :store_api, StoreAPI.Web.Endpoint,
  http: [port: port],
  url: [host: host, port: port]

# store config
config :store, :s3_shops,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_key: System.get_env("AWS_SECRET_ACCESS_KEY")

config :store, :s3_customers,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_key: System.get_env("AWS_SECRET_ACCESS_KEY")

config :store, :google_geocoding_api,
  api_key: System.get_env("GOOGLE_MAPS_GEOCODING_API_KEY")

config :store, :google_timezone_api,
  api_key: System.get_env("GOOGLE_MAPS_TIMEZONE_API_KEY")

config :store, :plivo,
  auth_id: System.get_env("PLIVO_AUTH_ID"),
  auth_token: System.get_env("PLIVO_AUTH_TOKEN")

config :store, :twilio,
  auth_id: System.get_env("TWILIO_AUTH_ID"),
  auth_token: System.get_env("TWILIO_AUTH_TOKEN"),
  msg_campaign_sid: System.get_env("TWILIO_MESSAGING_SERVICE_SID")

config :store, Store.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl_opts: [
    cacertfile: System.get_env("PG_SSL_CERT") || "/home/ubuntu/ssl/rds-ca-2015-root.pem"
  ]

domain = System.get_env("DOMAIN") || "acme.com"

config :store, Store.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  path: "#{domain}/reset/",
  path_admin: "#{domain}/reset/",
  path_base: "#{domain}/",
  from: "donotreply@acme.com",
  feedback: System.get_env("FEEDBACK_EMAIL"),
  relay: System.get_env("SMTP_RELAY"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  ssl: false,
  auth: :always,
  port: 587,
  retries: 2,
  no_mx_lookups: true

config :store, Store.NewBusinessMailer,
  path: "#{domain}",
  from: "donotreply@acme.com",
  relay: System.get_env("SMTP_RELAY"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  ssl: false,
  auth: :always,
  port: 587,
  retries: 2,
  no_mx_lookups: true

config :store, Store.Referrer,
  path: "#{domain}/r/"

config :store, Store.Surveyor,
  path: "#{domain}/s/"

config :pigeon, :fcm, fcm_default: %{
  key: System.get_env("FCM_KEY")
}

config :store, :paysafe,
  endpoint: System.get_env("PAYSAFE_API_ENDPOINT"),
  username: System.get_env("PAYSAFE_USERNAME"),
  password: System.get_env("PAYSAFE_PASSWORD"),
  account_id: System.get_env("PAYSAFE_ACCOUNT_ID")