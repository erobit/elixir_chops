defmodule StoreAPI.Web.Router do
  use StoreAPI.Web, :router

  forward("/crm", Crm.Api.Plug, name: "crm api plug")
  forward("/mobile", Mobile.Api.Plug, name: "mobile api plug")
  forward("/heartbeat", Heartbeat.Plug, name: "heartbeat plug")
  forward("/twilio", Twilio.Plug, name: "twilio sms plug")
  forward("/plivo", Plivo.Plug, name: "plivo sms plug")
  forward("/nexmo", Nexmo.Plug, name: "nexmo sms plug")
  forward("/brightlink", Brightlink.Plug, name: "brightlink sms plug")

  pipeline :api do
    plug(:accepts, ["json"])
    plug(StoreAPI.Plug.APIAuth)
  end

  pipeline :widget_api do
    plug(:accepts, ["json"])
  end

  scope "/api/v1", StoreAPI.Web do
    pipe_through(:api)
    get("/shops", ShopController, :index)
    get("/products", ProductController, :index)
  end

  scope "/widget", StoreAPI.Web do
    pipe_through(:widget_api)
    get("/location/:location_id", WidgetController, :index)
    post("/:location_id/submit", WidgetController, :submit)
  end

  # must be secured and only accessible internally
  forward("/admin", Admin.Api.Plug, name: "admin api plug")

  scope "/homescreen" do
    get("/", Homescreen.HomescreenController, :index)
  end

  if Application.get_env(:store_api, :environment) == :dev do
    forward("/crm-ql", Crm.GraphiQL.Plug, name: "crm grahpiql plug")
    forward("/mobile-ql", Mobile.GraphiQL.Plug, name: "mobile grahpiql plug")
    forward("/dev", Mail.Plug, name: "Mailbox plug")
  end
end
