defmodule Store.DevEmail do
  import Swoosh.Email

  def simple_message(msg, email_subject \\ "Development Simple Message") do
    new()
    |> to("eric@yourdomain.com")
    |> from({"Admin", "admin@yourdomain.in"})
    |> subject(email_subject)
    |> html_body("<h1>#{msg}</h1>")
    |> text_body(msg)
  end
end
