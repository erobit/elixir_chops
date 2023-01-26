defmodule Nexmo.API do
  use HTTPoison.Base

  @base_url "https://rest.nexmo.com"

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
    get!(endpoint, [], params: params)
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
    |> merge_credentials()
    |> Poison.encode!()
  end

  def process_response_body(body) do
    body
    |> Poison.Parser.parse!(keys: :atoms)
  end

  defp merge_credentials(params) do
    params = convert_to_map(params)

    Map.merge(params, %{
      api_key: api_key(),
      api_secret: api_secret()
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

  defp api_key do
    Application.get_env(:store, :nexmo)[:api_key] || System.get_env("NEXMO_API_KEY")
  end

  defp api_secret do
    Application.get_env(:store, :nexmo)[:api_secret] || System.get_env("NEXMO_API_SECRET")
  end
end
