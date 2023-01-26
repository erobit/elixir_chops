defmodule Store.Geo.Timezone do
  @moduledoc """
  Provides functions to interact with Google Timezone API.
  """

  def all_info(params) do
    result = Poison.decode!(make_request(params).body)

    case result["status"] do
      "ZERO_RESULTS" ->
        nil

      "OVER_QUERY_LIMIT" ->
        raise GoogleTimezoneApiException, message: "You have reached your query limit"

      "REQUEST_DENIED" ->
        raise GoogleTimezoneApiException, message: "Your request was denied"

      "INVALID_REQUEST" ->
        raise GoogleTimezoneApiException, message: "Your request was invalid"

      "UNKNOWN_ERROR" ->
        raise GoogleTimezoneApiException,
          message: "Unknown error, this may succeed if you try again"

      _ ->
        result
    end
  end

  def get_by_lat_lon(lat, lon) do
    timezone = all_info(%{location: "#{lat},#{lon}", timestamp: Timex.to_unix(Timex.now())})

    result = %{
      dst_offset: timezone["dstOffset"],
      raw_offset: timezone["rawOffset"],
      id: timezone["timeZoneId"],
      name: timezone["timeZoneName"]
    }

    {:ok, result}
  end

  defp make_request(params) do
    api_key = key()

    params =
      case api_key do
        nil -> params
        _ -> Map.put(params, :key, api_key)
      end

    HTTPoison.start()

    params
    |> URI.encode_query()
    |> build_url
    |> URI.decode()
    |> HTTPoison.get!()
  end

  defp build_url(params), do: "https://maps.googleapis.com/maps/api/timezone/json?" <> params

  defp key do
    Application.get_env(:store, :google_timezone_api)[:api_key]
  end
end
