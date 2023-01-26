defmodule Store.Messaging.SMS do
  alias Store.Messaging.SMSSetting

  def send(to, msg, url \\ "", sms_settings) do
    case sms_settings.provider do
      "twilio" -> Twilio.SMS.send(to, msg, url, sms_settings)
      "plivo" -> Plivo.SMS.send(to, msg, url, sms_settings)
      "nexmo" -> Nexmo.SMS.send(to, msg, url, sms_settings)
      "brightlink" -> Brightlink.SMS.send(to, msg, sms_settings)
    end
  end

  def send_campaign(campaign, sms_settings) do
    case sms_settings.provider do
      "twilio" -> Twilio.SMS.send_campaign(campaign, sms_settings)
      "plivo" -> Plivo.SMS.send_campaign(campaign, sms_settings)
      "nexmo" -> Nexmo.SMS.send_campaign(campaign, sms_settings)
      "brightlink" -> Brightlink.SMS.send_campaign(campaign, sms_settings)
    end
  end

  def send_import_sms(customer_import_id, customer, location_id, message, sms_settings) do
    case sms_settings.provider do
      "twilio" ->
        Twilio.SMS.send_import_sms(
          customer_import_id,
          customer,
          location_id,
          message,
          sms_settings
        )

      "plivo" ->
        Plivo.SMS.send_import_sms(
          customer_import_id,
          customer,
          location_id,
          message,
          sms_settings
        )

      "nexmo" ->
        Nexmo.SMS.send_import_sms(
          customer_import_id,
          customer,
          location_id,
          message,
          sms_settings
        )

      "brightlink" ->
        Brightlink.SMS.send_import_sms(
          customer_import_id,
          customer,
          location_id,
          message,
          sms_settings
        )
    end
  end

  defp get_available_tfns(provider) do
    tfns =
      case provider do
        "plivo" -> Plivo.Numbers.get_all()
        # need to implement for twilio
        "nexmo" -> Nexmo.Numbers.get_all()
        "brightlink" -> Brightlink.Numbers.get_all()
        _ -> []
      end

    acme_numbers = SMSSetting.get_all_phone_numbers(provider)

    Enum.filter(tfns, fn number ->
      Enum.member?(acme_numbers, number) == false
    end)
  end

  # Note: this is hardcoded for now, we should swap this out
  # to take the sms_settings provider as an argument instead
  # and come from the logged in user site's context
  def get_tfn() do
    case get_available_tfns("brightlink") |> List.first() do
      nil -> {:error, "no_tfns_available"}
      number -> {:ok, number}
    end
  end

  def check_tfn(phone, business_id) do
    case SMSSetting.in_use?(phone, business_id) do
      true -> {:ok, %{success: true}}
      false -> {:ok, %{success: false}}
    end
  end

  def set_alias(provider, phone, name) do
    case provider do
      "plivo" -> Plivo.Numbers.set_alias(phone, name)
      _ -> :noop
    end
  end
end
