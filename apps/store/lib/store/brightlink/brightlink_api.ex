defmodule Brightlink.API do
  use HTTPoison.Base

  def call(method, endpoint \\ "/", body \\ "") do
    __MODULE__.request!(
      method,
      endpoint,
      body,
      "User-Agent": "Acme",
      "Content-Type": "application/json"
    )
  end

  def post(endpoint, body) do
    call(:post, endpoint, body)
  end

  def get(endpoint, params \\ []) do
    params = merge_credentials(params)
    url = endpoint <> "?" <> URI.encode_query(params)
    options = [ssl: [{:versions, [:"tlsv1.2"]}]]
    get!(url, [], options)
  end

  def process_request_url(url) do
    base_url() <> url
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
  end

  defp merge_credentials(params) do
    params = convert_to_map(params)

    Map.merge(params, %{
      username: system_id(),
      password: password()
    })
  end

  defp convert_to_map(params) do
    for {key, val} <- params, into: %{} do
      cond do
        is_atom(key) -> {key, val}
        true -> {String.to_atom(key), val}
      end
    end
  end

  defp base_url do
    Application.get_env(:store, :brightlink)[:sms_api_endpoint] ||
      System.get_env("BRIGHTLINK_SMS_API_ENDPOINT")
  end

  defp system_id do
    Application.get_env(:store, :brightlink)[:system_id] || System.get_env("BRIGHTLINK_SYSTEM_ID")
  end

  defp password do
    Application.get_env(:store, :brightlink)[:password] || System.get_env("BRIGHTLINK_PASSWORD")
  end
end
