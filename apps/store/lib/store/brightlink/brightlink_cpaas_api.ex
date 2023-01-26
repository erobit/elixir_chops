defmodule Brightlink.CPAAS.API do
  use HTTPoison.Base

  def call(method, endpoint \\ "/", body \\ "") do
    token = get_token()

    __MODULE__.request!(
      method,
      endpoint,
      body,
      "Content-Type": "application/json",
      Authorization: "Bearer #{token}"
    )
  end

  def get_token() do
    body = "username=#{username()}&password=#{password()}&grant_type=password"

    result =
      __MODULE__.request!(
        :post,
        "/oauth/token",
        body,
        [
          Accept: "application/vnd.brightlink.v1+json",
          "Content-Type": "application/x-www-form-urlencoded"
        ],
        hackney: [basic_auth: {api_key(), api_secret()}]
      ).body

    result["access_token"]
  end

  def post(endpoint, body) do
    call(:post, endpoint, body)
  end

  def get(path, params \\ []) do
    options = [ssl: [{:versions, [:"tlsv1.2"]}]]
    get!(path, params, options)
  end

  def process_request_url(url) do
    get_base_url() <> url
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
    |> Poison.decode!()
  end

  defp get_base_url do
    Application.get_env(:store, :brightlink)[:cpaas_api_endpoint] ||
      System.get_env("BRIGHTLINK_CPAAS_API_ENDPOINT")
  end

  def api_key do
    Application.get_env(:store, :brightlink)[:cpaas_api_key] ||
      System.get_env("BRIGHTLINK_CPAAS_API_KEY")
  end

  def api_secret do
    Application.get_env(:store, :brightlink)[:cpaas_api_secret] ||
      System.get_env("BRIGHTLINK_CPAAS_API_SECRET")
  end

  defp username do
    Application.get_env(:store, :brightlink)[:cpaas_username] ||
      System.get_env("BRIGHTLINK_CPAAS_USERNAME")
  end

  defp password do
    Application.get_env(:store, :brightlink)[:cpaas_password] ||
      System.get_env("BRIGHTLINK_CPAAS_PASSWORD")
  end
end
