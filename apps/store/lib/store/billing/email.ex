defmodule Billing.Email do
  import Swoosh.Email
  import Store.Mailer.Template

  def send_error(profile, to_email, type) do
    error_type =
      case type do
        "expired" -> "has expired"
        "declined" -> "was declined"
      end

    subdomain = profile.location.business.subdomain
    location_id = profile.location.id

    config = Application.get_env(:store, Store.Mailer)
    prefix = config[:prefix]
    path_base = config[:path_base]
    sent_from = config[:from]

    subject = "Acme Billing : Action Required"
    title = "Your credit card #{error_type}"

    subtitle =
      "The credit card you have selected for payments #{error_type}. Please change your active card or add a new card to ensure there is no interruption of service."

    link_text = "#{prefix}#{subdomain}.#{path_base}"
    link_url = "#{prefix}#{subdomain}.#{path_base}billing/#{location_id}"

    html = link_template(title, subtitle, link_text, link_url) |> base_template()

    new()
    |> to(to_email)
    |> from({"Acme", sent_from})
    |> subject(subject)
    |> html_body(html)
    |> text_body(title <> "\r\n" <> subtitle <> "\r\n" <> link_url)
  end
end
