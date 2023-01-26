defmodule Brightlink.Plug do
  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:name, Keyword.get(opts, :name, "Brightlink SMS response plug"))
    |> Brightlink.Router.call(opts)
  end
end

defmodule Brightlink.Router do
  use Plug.Router
  alias Store
  require Logger

  plug(:match)
  plug(:dispatch)

  get "/senddlr" do
    payload = conn.params
    uuid = payload["id"]
    status = payload["status"]

    status =
      case status do
        "1" -> "sent"
        "2" -> "delivered"
        "3" -> "failed"
        "4" -> "deleted"
        "5" -> "undeliverable"
        "6" -> "accepted"
        "7" -> "unknown"
        "8" -> "rejected"
        _ -> "failed"
      end

    error =
      case status in ["failed", "deleted", "undeliverable", "unknown", "rejected"] do
        true ->
          code = payload["status"] |> String.to_integer()
          message = "Failed"
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
    content = payload["text"]

    # trim the 1 off of 11 character phone numbers
    to =
      case String.length(to) do
        11 -> String.slice(to, 1..-1)
        _ -> to
      end

    Logger.info("Brightlink SMS incoming Log", event: %{brightlink_sms_incoming_log: conn.params})

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

    if Regex.match?(~r/unstop/iu, content) || Regex.match?(~r/start/iu, content) do
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
