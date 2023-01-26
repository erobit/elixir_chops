defmodule Store.EmployeeEmail do
  import Swoosh.Email
  import Store.Mailer.Template

  Application.get_env(:store, :s3_shops)

  def password_reset_email(employee_reset) do
    config = Application.get_env(:store, Store.Mailer)
    prefix = config[:prefix]
    path = config[:path]
    path_base = config[:path_base]
    sent_from = config[:from]

    title = "Hello and welcome to Acme"
    subtitle = "Click the following URL to set your password"
    link_text = "#{prefix}#{employee_reset.subdomain}.#{path_base}"
    link_url = "#{prefix}#{employee_reset.subdomain}.#{path}#{employee_reset.id}"

    html = link_template(title, subtitle, link_text, link_url) |> base_template()

    new()
    |> to(employee_reset.email)
    |> from({"Acme", sent_from})
    |> subject("Welcome to Acme!")
    |> html_body(html)
    |> text_body(
      "Hello and welcome to Acme\nEnter the following url in your browser to set your password\n#{
        link_url
      }\n"
    )
  end

  def customer_export_email(business, employee, token) do
    config = Application.get_env(:store, Store.Mailer)
    prefix = config[:prefix]
    path = config[:path_base]
    sent_from = config[:from]

    title = "Customer Export Link"
    subtitle = "Click the following link to download your customer data"
    link_text = "#{prefix}#{business.subdomain}.#{path}"
    link_url = "#{link_text}csv?token=#{token}"

    html = link_template(title, subtitle, link_text, link_url) |> base_template()

    new()
    |> to(employee.email)
    |> from({"Platform", sent_from})
    |> subject("Customer Export Link")
    |> html_body(html)
    |> text_body("Please paste the following link in your browser: #{link_url}")
  end

  @new_biz_message [
    "Salutations,",
    "Welcome to the family! We are very excited that you have chosen us for your loyalty program, and look forward to working with you to make it a great success.",
    "Expect to receive your official launch kit and download cards (shipped separately) within 5-7 business days at your business address.",
    # @TODO - Decide how to handle pre-generating a QR code ------> "Please print the attached QR stamp and place one QR stamp at each checkout station.",
    "Your CRM website has been created and is available at the following url:",
    "%url%",
    "You will receive an e-mail shortly with password reset instructions to log in to the CRM.",
    "If you have any questions or problems in regards to setting up Acme, or have not received your launch kit, please don't hesitate to call or email us."
  ]
  @new_biz_text_suffix "Thanks,\r\nPlatform Team\r\ninfo@mydomain.com"

  def new_business_welcome_email(employee_email, subdomain) do
    config = Application.get_env(:store, Store.NewBusinessMailer)
    prefix = config[:prefix]
    path = config[:path]
    sent_from = config[:from]
    url = "#{prefix}#{subdomain}.#{path}"

    html = welcome_template(url)

    new()
    |> to(employee_email)
    |> from({"Acme", sent_from})
    |> subject("Welcome to Acme")
    |> html_body(html)
    |> text_body(
      replace_url(Enum.join(Enum.map(@new_biz_message, fn m -> "#{m}\r\n\r\n" end)), url) <>
        @new_biz_text_suffix
    )
  end

  defp replace_url(message, url) do
    Regex.replace(~r/%url%/, message, url)
  end

  def admin_password_reset_email(admin_reset, subdomain) do
    config = Application.get_env(:store, Store.Mailer)
    prefix = config[:prefix]
    sent_from = config[:from]

    path =
      case subdomain do
        nil -> config[:path_admin]
        _ -> ".#{config[:path_admin]}"
      end

    title = "Hello and welcome to Acme"
    subtitle = "Click the following URL to set your password"
    link_text = "#{prefix}#{subdomain}#{path}"
    link_url = "#{prefix}#{subdomain}#{path}#{admin_reset.id}"

    html = link_template(title, subtitle, link_text, link_url) |> base_template()

    new()
    |> to(admin_reset.email)
    |> from({"Acme", sent_from})
    |> subject("Welcome to Acme!")
    |> html_body(html)
    |> text_body(
      "Hello and welcome to Acme\nEnter the following url in your browser to set your password\n#{
        link_url
      }\n"
    )
  end
end
