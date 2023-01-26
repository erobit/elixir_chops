defmodule Facebook.API do
  use HTTPoison.Base

  @version "v2.11"
  @base_url "https://graph.facebook.com/#{@version}"

  def call(method, endpoint \\ "/", body \\ "") do
    __MODULE__.request!(method, endpoint, body,
      "User-Agent": "ElixirAPI",
      "Content-Type": "application/json"
    )
  end

  def me(token) do
    call(:get, "/me/?access_token=#{token}")
  end

  def process_request_url(url) do
    @base_url <> url
  end

  def process_request_body(body) when is_binary(body) do
    body
  end

  def process_request_body(body) do
    body
    |> Enum.into(%{})
    |> Poison.encode!()
  end

  def process_response_body(body) do
    body
    |> Poison.Parser.parse!(keys: :atoms)
  end
end
