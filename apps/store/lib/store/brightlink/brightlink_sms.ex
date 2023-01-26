defmodule Brightlink.SMS do
  alias Store.Messaging.SMSLog
  alias Store.Loyalty.ReferralLink
  require Logger

  #####
  # Public API
  #####

  @doc """
  The send_sms/4 function sends an sms to a
  given phone number from a given phone number.

  ## Example:
      ```
      iex(1)> Brightlink.SMS.send("15005550001", "test text", %{phone_number: "15005550006", send_distributed: false})
      ```
  """
  def send(to, msg, _url \\ "", sms_settings) do
    params = [
      from: sms_settings.phone_number,
      to: to,
      text: msg
    ]

    result = Brightlink.API.get("/sendsms", params).body
    result = clean_html(result)
    {:ok, result}
  end

  defp clean_html(html) do
    {:ok, document} = Floki.parse_document(html)

    document
    |> Floki.find("body")
    |> Floki.text()
    |> String.split(".", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn item ->
      item
      |> String.split(":", trim: true)
      |> Enum.map(&String.trim/1)
      |> List.to_tuple()
    end)
    |> Map.new()
  end

  def send_campaign(campaign, sms_settings) do
    url = campaign_response_endpoint()
    # Logger.info("Sending Nexmo SMS Campaign", event: %{from: from, campaign: campaign})
    business = Store.get_business(campaign.business_id)
    location_id = campaign.location_id

    results =
      Enum.map(campaign.customers, fn customer ->
        # throttle each iteration through the loop for sending sms
        # sms_throttle_delay()

        cipher = ReferralLink.generate_hash([campaign.id, customer.id, location_id])
        intent = Store.get_intent_base() <> "/c/#{cipher}"

        stop = "\r\n\r\n\r\nReply STOP to opt out."

        message =
          Store.replace_campaign_message_variables(
            campaign,
            intent,
            customer,
            location_id,
            business.subdomain
          ) <> stop

        {:ok, result} = send(customer.phone, message, url, sms_settings)

        sms_send_log = %{phone: customer.phone, message: message, url: url, result: result}
        Logger.info("Brightlink SMS Send Log", event: %{brightlink_sms_send_log: sms_send_log})

        log = %{
          entity_id: campaign.id,
          customer_id: customer.id,
          location_id: location_id,
          phone: customer.phone,
          type: "campaign",
          message: message
        }

        code = result["code"]

        log =
          case code do
            # success
            "0" ->
              Map.merge(log, %{
                uuid: result["id"],
                status: "queued"
              })

            _ ->
              Store.log_campaign_bounce(campaign.id, customer.id, location_id, "error")
              error_message = result[code]

              Map.merge(log, %{
                uuid: :os.system_time(:seconds),
                status: "error",
                error_code: code |> String.to_integer(),
                error_message: error_message
              })
          end

        log
        |> SMSLog.create()

        customer
      end)

    {:ok, results}
  end

  def send_import_sms(customer_import_id, customer, location_id, message, sms_settings) do
    # throttle sending sms
    # sms_throttle_delay()

    url = campaign_response_endpoint()
    {:ok, result} = send(customer.phone, message, url, sms_settings)

    if result["code"] == "0" do
      %{
        entity_id: customer_import_id,
        customer_id: customer.id,
        location_id: location_id,
        uuid: result["id"],
        phone: customer.phone,
        type: "customer import",
        status: "queued",
        message: message
      }
      |> SMSLog.create()
    else
      {:ok, nil}
    end
  end

  defp sms_throttle_delay() do
    timeout = System.get_env("SMS_THROTTLE_DELAY") || 1000
    Process.sleep(timeout)
  end

  def campaign_response_endpoint() do
    domain = System.get_env("DOMAIN")

    case System.get_env("ENV") do
      "demo" ->
        "https://api.#{domain}/brightlink/senddlr"

      "prod" ->
        "https://api.#{domain}/brightlink/senddlr"

      "staging" ->
        "https://api.#{domain}/brightlink/senddlr"

      _ ->
        "https://webhook.site/ae9456cb-a9de-448a-84e6-7797cd86d954"
        # "https://webhook.site/#/83053100-98e5-4701-9a8f-a72ac87e06b5"
    end
  end
end
