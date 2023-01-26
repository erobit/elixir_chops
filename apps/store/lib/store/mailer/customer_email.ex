defmodule Store.CustomerEmail do
  import Swoosh.Email
  import Store.Mailer.Template

  Application.get_env(:store, :s3_shops)

  def password_reset_email(customer_reset) do
    domain = System.get_env("DOMAIN")
    config = Application.get_env(:store, Store.Mailer)
    # prefix = config[:prefix]
    # path = config[:path]
    # {"Admin", "admin@yourdomain.in"}
    sent_from = config[:from]
    url = "https://#{domain}/a/#{customer_reset.code}"
    intent_link = "<a href=\"#{url}\">#{url}</a>"

    new()
    |> to("eric@yourdomain.com")
    |> from(sent_from)
    |> subject("Magic Login Link [Temporary]")
    |> html_body(
      "<h1>Magic Login Link</h1><p>Click the following intent to automagically login</p><p>#{
        intent_link
      }</p>"
    )
    |> text_body("Magic Login Link\nEnter the following code to login\n#{url}\n")
  end

  def send_referral_sms_email(msg) do
    config = Application.get_env(:store, Store.Mailer)
    sent_from = config[:from]

    new()
    |> to("eric@yourdomain.com")
    |> from(sent_from)
    |> subject("Referral Intent")
    |> html_body(msg)
    |> text_body(msg)
  end

  def send_welcome_sms_email(msg) do
    config = Application.get_env(:store, Store.Mailer)
    sent_from = config[:from]

    new()
    |> to("eric@yourdomain.com")
    |> from(sent_from)
    |> subject("Join Shop Welcome SMS")
    |> html_body(msg)
    |> text_body(msg)
  end

  def send_download_sms_email(msg) do
    config = Application.get_env(:store, Store.Mailer)
    sent_from = config[:from]

    new()
    |> to("eric@yourdomain.com")
    |> from(sent_from)
    |> subject("Download app SMS")
    |> html_body(msg)
    |> text_body(msg)
  end

  def send_campaign_emails(customers, msg) do
    config = Application.get_env(:store, Store.Mailer)
    sent_from = config[:from]
    recipients = customers |> Enum.map(fn c -> c.phone end)
    text_msg = Enum.join(recipients, "\r\n") <> "\r\n" <> msg
    html_msg = Enum.join(recipients, "<br/>") <> "<br/>" <> msg

    new()
    |> to("eric@yourdomain.com")
    |> from(sent_from)
    |> subject("Campaign SMS DEV to recipients")
    |> html_body(html_msg)
    |> text_body(text_msg)
  end

  def feedback(customer, feedback) do
    config = Application.get_env(:store, Store.Mailer)
    sent_from = config[:from]
    feedback_to = config[:feedback]

    customer_details =
      "<b>ID:</b>#{customer.id}\n<b>Name:</b> #{customer.first_name} #{customer.last_name}\n<b>phone:</b> #{
        customer.phone
      }"

    customer_details_text = HtmlSanitizeEx.strip_tags(customer_details)

    html = feedback_template(customer_details, feedback) |> base_template()

    new()
    |> to(feedback_to)
    |> from(sent_from)
    |> subject("Mobile App : Customer Feedback")
    |> html_body(html)
    |> text_body("Customer\n\n#{customer_details_text}\n\nFeedback\n\n#{feedback}")
    |> Store.Mailer.deliver()
  end
end
