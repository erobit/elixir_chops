defmodule Plivo.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "Plivo response plug"))
    |> Plivo.Router.call(opts)
  end
end

defmodule Plivo.Router do
  use Plug.Router
  alias Store
  require Logger

  @error_reasons %{
    10 => "Invalid message",
    20 => "Network error",
    30 => "Spam detected",
    40 => "Invalid source number",
    50 => "Invalid destination number",
    60 => "Loop detected",
    70 => "Destination permantently unavailable",
    80 => "Destination temporarily unavailable",
    90 => "No route available",
    100 => "Prohibited by carrier",
    110 => "Message too long",
    200 => "Source number blocked by STOP from destination number",
    300 => "Failed to dispatch message",
    420 => "Message expired",
    900 => "Insufficient credit",
    910 => "Account disabled",
    1000 => "Unknown error"
  }

  plug(:match)
  plug(:dispatch)

  # Status -> "queued", "sent", "failed", "delivered", "undelivered" or "rejected"
  post "/campaign" do
    payload = conn.params
    uuid = payload["MessageUUID"]
    status = payload["Status"]

    # https://api-reference.plivo.com/latest/curl/resources/message/sms-error-codes
    error =
      case status in ["failed", "undelivered"] do
        true ->
          code = payload["ErrorCode"] |> String.to_integer()
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

    send_resp(conn, 200, "")
  end

  post "/incoming" do
    payload = conn.params
    from = payload["From"]
    to = payload["To"]
    content = payload["Text"]

    Logger.info("Plivo SMS incoming Log", event: %{plivo_sms_incoming_log: conn.params})

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
