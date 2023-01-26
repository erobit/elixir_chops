use Mix.Config

## Logger
config :logger, level: :debug

## Repo
config :store, ecto_repos: [Store.Repo]

config :store, :s3_shops,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket_name: "shops",
  zone: "ca-central-1"

config :store, :s3_customers,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket_name: "customers",
  zone: "ca-central-1"

config :store, Store.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  prefix: "http://",
  path: "localhost:3000/reset/",
  path_admin: "localhost:3001/reset/",
  path_base: "localhost:3000/",
  from: "donotreply@domain.com",
  domain: "domain.com",
  feedback: System.get_env("FEEDBACK_EMAIL")

config :store, Store.NewBusinessMailer,
  adapter: Swoosh.Adapters.SMTP,
  prefix: "http://",
  path: "localhost:3000",
  from: "donotreply@domain.com",
  domain: "domain.com"

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

config :store, :nexmo,
  sms_number: System.get_env("NEXMO_SMS_NUMBER"),
  api_key: System.get_env("NEXMO_API_KEY"),
  api_secret: System.get_env("NEXMO_API_SECRET")

config :store, :brightlink,
  system_id: System.get_env("BRIGHTLINK_SYSTEM_ID"),
  password: System.get_env("BRIGHTLINK_PASSWORD"),
  sms_api_endpoint: System.get_env("BRIGHTLINK_SMS_API_ENDPOINT"),
  cpaas_api_endpoint: System.get_env("BRIGHTLINK_CPAAS_API_ENDPOINT"),
  cpaas_username: System.get_env("BRIGHTLINK_CPAAS_USERNAME"),
  cpaas_password: System.get_env("BRIGHTLINK_CPAAS_PASSWORD"),
  cpaas_api_key: System.get_env("BRIGHTLINK_CPAAS_API_KEY"),
  cpaas_api_secret: System.get_env("BRIGHTLINK_CPAAS_API_SECRET")

config :pigeon, :fcm, fcm_default: %{
  key: System.get_env("FCM_KEY")
}

config :ex_money,
  default_cldr_backend: Store.Cldr

config :store, Store.Scheduler,
  global: true,
  jobs: [
    pacific_15_campaigns: [
      schedule: {:cron, "0,15,30,45 * * * *"}, # Runs every 15 minutes and on the hour
      task: {Store, :send_scheduled_campaigns, ["Pacific"]},
      timezone: "America/Vancouver"
    ],
    delete_employee_expired_resets: [
      schedule: "@weekly",  # Runs weekly
      task: {Store, :delete_employee_expired_resets, []},
      timezone: "America/Toronto"
    ],
    delete_customer_expired_resets: [
      schedule: "@weekly",  # Runs weekly
      task: {Store, :delete_customer_expired_resets, []},
      timezone: "America/Toronto"
    ],
    delete_admin_employee_expired_resets: [
      schedule: "@weekly",  # Runs weekly
      task: {Store, :delete_admin_employee_expired_resets, []},
      timezone: "America/Toronto"
    ],
    delete_expired_authorization_tokens: [
      schedule: "@weekly", # Runs weekly
      task: {Store, :delete_expired_authorization_tokens, []},
      timezone: "America/Toronto"
    ],
    process_monthly_billing: [
     schedule: {:cron, "0 12 * * * *"},   # daily at 12:00pm
     task: {Store.Billing, :process_monthly_payments, []},
     timezone: "America/Toronto"
    ]
  ]

import_config "#{Mix.env}.exs"