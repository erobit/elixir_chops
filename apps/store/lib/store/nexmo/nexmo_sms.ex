defmodule Nexmo.SMS do
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
      iex(1)> Nexmo.SMS.send("15005550001", "test text", %{phone_number: "15005550006", send_distributed: false})
      ```
  """
  def send(to, msg, url \\ "", sms_settings) do
    params = [
      from: sms_settings.phone_number,
      to: to,
      text: msg
    ]

    params =
      case url do
        "" -> params
        url -> params ++ [callback: url]
      end

    result = Nexmo.API.post("/sms/json", params).body
    {:ok, result}
  end

  def send_campaign(campaign, sms_settings) do
    url = campaign_response_endpoint()
    # Logger.info("Sending Nexmo SMS Campaign", event: %{from: from, campaign: campaign})
    business = Store.get_business(campaign.business_id)
    location_id = campaign.location_id

    results =
      Enum.map(campaign.customers, fn customer ->
        # throttle each iteration through the loop for sending sms
        sms_throttle_delay()

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
        Logger.info("Nexmo SMS Send Log", event: %{plivo_sms_send_log: sms_send_log})

        log = %{
          entity_id: campaign.id,
          customer_id: customer.id,
          location_id: location_id,
          phone: customer.phone,
          type: "campaign",
          message: message
        }

        result = List.first(result.messages)

        log =
          case result.status do
            # success
            "0" ->
              Map.merge(log, %{
                uuid: result."message-id",
                status: "queued"
              })

            _ ->
              Store.log_campaign_bounce(campaign.id, customer.id, location_id, "error")

              Map.merge(log, %{
                uuid: :os.system_time(:seconds),
                status: "error",
                error_code: nil,
                error_message: result.status
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
    sms_throttle_delay()

    url = campaign_response_endpoint()
    {:ok, result} = send(customer.phone, message, url, sms_settings)

    result = List.first(result.messages)

    if result.status == "0" do
      %{
        entity_id: customer_import_id,
        customer_id: customer.id,
        location_id: location_id,
        uuid: result["message-id"],
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
        "https://api.#{domain}/nexmo/campaign"

      "prod" ->
        "https://api.#{domain}/nexmo/campaign"

      "staging" ->
        "https://api.#{domain}/nexmo/campaign"

      _ ->
        "https://webhook.site/asdfasdfasdfasdfasdf"
    end
  end
end
