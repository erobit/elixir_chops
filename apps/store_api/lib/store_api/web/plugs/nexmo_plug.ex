defmodule Nexmo.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "Nexmo SMS response plug"))
    |> Nexmo.Router.call(opts)
  end
end

defmodule Nexmo.Router do
  use Plug.Router
  alias Store
  require Logger

  # https://developer.nexmo.com/messaging/sms/guides/delivery-receipts#dlr-error-codes
  @error_reasons %{
    0 => "Delivered",
    1 => "Unknown",
    2 => "Absent Subscriber - Temporary",
    3 => "Absent Subscriber - Permanent",
    4 => "Call Barred by User",
    5 => "Portability Error",
    6 => "Anti-Spam Rejection",
    7 => "Handset Busy",
    8 => "Network Error",
    9 => "Illegal Number",
    10 => "Illegal Message",
    11 => "Unroutable",
    12 => "Destination Unreachable",
    13 => "Subscriber Age Restriction",
    14 => "Number Blocked by Carrier",
    15 => "Prepaid Insufficient Funds",
    99 => "General Error"
  }

  plug(:match)
  plug(:dispatch)

  # Status -> "delivered", "expired", "failed", "rejected", "accepted", "buffered" or "unknown"
  get "/campaign" do
    params = conn.query_params
    uuid = params["messageId"]
    status = params["status"]

    # https://developer.nexmo.com/api/sms#delivery-receipt
    error =
      case status in ["failed", "rejected", "expired"] do
        true ->
          code = params["err-code"] |> String.to_integer()
          message = Map.get(@error_reasons, code, "Error is not defined in @error_reasons")
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
    from = payload["msisdn"]
    to = payload["to"]
    content = payload["text"]

    Logger.info("Nexmo SMS incoming Log", event: %{nexmo_sms_incoming_log: conn.params})

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
