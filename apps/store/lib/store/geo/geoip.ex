defmodule Store.Geo.Ip do
  @moduledoc """
  Provides functions to interact with FreeGeoIp IP location API.
  """

  def all_info(ip) do
    result = Poison.decode!(make_request(ip).body)

    case result["status"] do
      "ZERO_RESULTS" ->
        nil

      "OVER_QUERY_LIMIT" ->
        raise FreeGeoIpApiException, message: "You have reached your query limit"

      "REQUEST_DENIED" ->
        raise FreeGeoIpApiException, message: "Your request was denied"

      "INVALID_REQUEST" ->
        raise FreeGeoIpApiException, message: "Your request was invalid"

      "UNKNOWN_ERROR" ->
        raise FreeGeoIpApiException, message: "Unknown error, this may succeed if you try again"

      _ ->
        result
    end
  end

  def locate(ip) do
    result = all_info(ip)

    geo_data = %{
      city: result["city"],
      country_code: result["country_code"],
      country_name: result["latitude"],
      ip: result["ip"],
      latitude: result["latitude"],
      longitude: result["longitude"],
      metro_code: result["metro_code"],
      region_code: result["region_code"],
      region_name: result["region_name"],
      time_zone: result["time_zone"],
      zip_code: result["zip_code"]
    }

    {:ok, geo_data}
  end

  defp make_request(ip) do
    HTTPoison.start()

    ip
    |> build_url
    |> HTTPoison.get!()
  end

  defp build_url(ip), do: "freegeoip.net/json/" <> ip
end
