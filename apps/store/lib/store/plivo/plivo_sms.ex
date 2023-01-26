defmodule Plivo.SMS do
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
      iex(1)> Plivo.SMS.send("15005550001", "test text", %{phone_number: "15005550006", send_distributed: false})
      ```

  if settings.send_distributed, it will send using
  Plivo's Power Pack feature which distributes the load 
  over a block of local SMS numbers.

  Critical: Before we can put this into production we need
  to make sure that all existing customers who have
  responded with STOP messages will not be delivered
  SMS messages from new phone numbers whether Toll Free
  or Local. The same goes if we swap phone numbers in the
  Acme admin.
  """
  def send(to, msg, url \\ "", sms_settings) do
    params = [
      dst: to,
      text: msg,
      url: url,
      method: "POST"
    ]

    params =
      case sms_settings.send_distributed do
        true -> params ++ [powerpack_uuid: sms_settings.distributed_uuid]
        false -> params ++ [src: sms_settings.phone_number]
      end

    result = Plivo.API.post("/Message/", params).body
    {:ok, result}
  end

  def send_campaign(campaign, sms_settings) do
    url = campaign_response_endpoint()
    # Logger.info("Sending Plivo SMS Campaign", event: %{from: from, campaign: campaign})
    business = Store.get_business(campaign.business_id)
    location_id = campaign.location_id

    results =
      Enum.map(campaign.customers, fn customer ->
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
        Logger.info("Plivo SMS Send Log", event: %{plivo_sms_send_log: sms_send_log})

        log = %{
          entity_id: campaign.id,
          customer_id: customer.id,
          location_id: location_id,
          phone: customer.phone,
          type: "campaign",
          message: message
        }

        log =
          case Map.has_key?(result, :error) do
            true ->
              Store.log_campaign_bounce(campaign.id, customer.id, location_id, "error")

              Map.merge(log, %{
                uuid: :os.system_time(:seconds),
                status: "error",
                error_code: nil,
                error_message: result.error
              })

            false ->
              Map.merge(log, %{
                uuid: List.first(result.message_uuid),
                status: "queued"
              })
          end

        log
        |> SMSLog.create()

        customer
      end)

    {:ok, results}
  end

  def send_import_sms(customer_import_id, customer, location_id, message, sms_settings) do
    url = campaign_response_endpoint()
    {:ok, result} = send(customer.phone, message, url, sms_settings)

    if Map.has_key?(result, :message_uuid) do
      %{
        entity_id: customer_import_id,
        customer_id: customer.id,
        location_id: location_id,
        uuid: List.first(result.message_uuid),
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

  def campaign_response_endpoint() do
    domain = System.get_env("DOMAIN")

    case System.get_env("ENV") do
      "demo" -> "https://api.#{domain}/plivo/campaign"
      "prod" -> "https://api.#{domain}/plivo/campaign"
      "staging" -> "https://api.#{domain}/plivo/campaign"
      _ -> "https://webhook.site/#/83053100-98e5-4701-9a8f-a72ac87e06b5"
    end
  end
end
