defmodule Twilio.SMS do
  alias Store.Messaging.SMSLog
  alias Store.Loyalty.ReferralLink

  #####
  # Public API
  #####

  @doc """
  The send_sms/4 function sends an sms to a
  given phone number from a given phone number.

  ## Example:
      ```
      iex(1)> Twilio.SMS.send("15005550001", "test text", %{phone_number: "15005550006", send_distributed: false})
      ```
  """

  # @spec send(String.t(), String.t(), String.t()) :: map()
  def send(to, msg, url \\ "", sms_settings) do
    params = [
      To: "+" <> to,
      Body: msg,
      StatusCallback: url
    ]

    params =
      case sms_settings.send_distributed do
        true -> params ++ [MessagingServiceSid: sms_settings.distributed_uuid]
        false -> params ++ [From: "+" <> sms_settings.phone_number]
      end

    result = Twilio.API.post("/Messages.json", params).body
    {:ok, result}
  end

  def send_campaign(campaign, sms_settings) do
    url = campaign_response_endpoint()

    # from = "+15005550006"

    # determine the number of messages to send
    number_to_send = length(campaign.customers)

    {:ok, %{number_to_send: number_to_send}} =
      Store.campaign_send_stats(campaign.location_id, number_to_send)

    # limit customers to available sms messages left for the month
    customers = Enum.take(campaign.customers, number_to_send)

    business = Store.get_business(campaign.business_id)

    location_id = campaign.location_id

    results =
      Enum.map(customers, fn customer ->
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

        # to = "+15005550009"
        to = customer.phone
        {:ok, result} = send(to, message, url, sms_settings)

        # @TODO - catch error code result.error == 21610
        # when customers are STOP / blacklisted and we can turn their notifications 
        # services off for this business_id

        if Map.has_key?(result, :sid) do
          %{
            entity_id: campaign.id,
            customer_id: customer.id,
            location_id: location_id,
            uuid: result.sid,
            phone: customer.phone,
            type: "campaign",
            status: "queued",
            message: message
          }
          |> SMSLog.create()
        else
          %{
            entity_id: campaign.id,
            customer_id: customer.id,
            location_id: location_id,
            uuid: "error",
            phone: customer.phone,
            type: "campaign",
            status: "error",
            message: Integer.to_string(result.code) <> " : " <> result.message
          }
          |> SMSLog.create()

          Store.log_campaign_bounce(campaign.id, customer.id, location_id, "error")
          {:ok, nil}
        end

        customer
      end)

    {:ok, results}
  end

  def send_import_sms(customer_import_id, customer, location_id, message, sms_settings) do
    url = campaign_response_endpoint()
    {:ok, result} = send(customer.phone, message, url, sms_settings)

    if Map.has_key?(result, :sid) do
      %{
        entity_id: customer_import_id,
        customer_id: customer.id,
        location_id: location_id,
        uuid: result.sid,
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
      "demo" -> "https://api.#{domain}/twilio/campaign"
      "staging" -> "https://api.#{domain}/twilio/campaign"
      "prod" -> "https://api.#{domain}/twilio/campaign"
      _ -> "https://api.#{domain}/twilio/campaign"
    end
  end
end
