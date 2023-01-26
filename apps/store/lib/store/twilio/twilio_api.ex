defmodule Twilio.API do
  use HTTPoison.Base

  @version "2010-04-01"
  @base_url "https://api.twilio.com/#{@version}"

  def call(method, endpoint \\ "/", body \\ "") do
    __MODULE__.request!(
      method,
      endpoint,
      body,
      ["User-Agent": "ElixirTwilio", "Content-Type": "application/json"],
      hackney: [basic_auth: {auth_id(), auth_token()}]
    )
  end

  def post(endpoint, body) do
    call(:post, endpoint, body)
  end

  def process_request_url(url) do
    @base_url <> "/Accounts/" <> auth_id() <> url
  end

  def process_request_body(body) when is_binary(body) do
    body
  end

  def process_request_body(body) do
    {:form, body}
  end

  def process_response_body(body) do
    body
    |> Poison.Parser.parse!(keys: :atoms)
  end

  defp auth_id do
    Application.get_env(:store, :twilio)[:auth_id] || System.get_env("TWILIO_AUTH_ID")
  end

  defp auth_token do
    Application.get_env(:store, :twilio)[:auth_token] || System.get_env("TWILIO_AUTH_TOKEN")
  end
end
