defmodule Twilio.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "Twilio SMS response plug"))
    |> Twilio.Router.call(opts)
  end
end

defmodule Twilio.Router do
  use Plug.Router
  alias Store
  require Logger

  plug(:match)
  plug(:dispatch)

  # Status -> "queued", "sent", "failed", "delivered", "undelivered" or "rejected"
  post "/campaign" do
    payload = conn.params
    uuid = payload["MessageSid"]
    status = payload["MessageStatus"]

    # https://www.twilio.com/docs/sms/api/message-resource#message-status-values
    error =
      case status in ["failed", "undelivered"] do
        true ->
          code = payload["ErrorCode"] |> String.to_integer()
          message = payload["ErrorMessage"]
          %{code: code, message: message}

        false ->
          %{code: nil, message: nil}
      end

    with {:ok, log} <- Store.get_sms(uuid),
         {:ok, _updated} <- Store.update_sms(uuid, status, error),
         {:ok, _log_bounce} <-
           Store.log_campaign_bounce(log.entity_id, log.customer_id, log.location_id, status) do
      {:ok, true}
    else
      err -> err
    end

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, "<Response/>")
  end

  post "/incoming" do
    payload = conn.params
    from = payload["from"]
    to = payload["to"]
    content = payload["content"]

    Logger.info("Twilio SMS incoming Log", event: %{twilio_sms_incoming_log: conn.params})

    if Regex.match?(~r/stop/iu, content) do
      with {:ok, customer} <- Store.get_customer_by_phone(from),
           {:ok, location_ids} <- Store.locations_by_phone(to),
           {:ok, _ignore} <-
             Store.toggle_opted_and_notifications(location_ids, customer.id, false, "sms-stop") do
        {:ok, true}
      else
        err -> err
      end
    end

    if Regex.match?(~r/unstop/iu, content) do
      with {:ok, customer} <- Store.get_customer_by_phone(from),
           {:ok, location_ids} <- Store.locations_by_phone(to),
           {:ok, _ignore} <-
             Store.toggle_opted_and_notifications(location_ids, customer.id, true, "sms-unstop") do
        {:ok, true}
      else
        err -> err
      end
    end

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, "<Response/>")
  end
end
