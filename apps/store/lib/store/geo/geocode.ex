defmodule Store.Geo.Geocode do
  @moduledoc """
  Provides functions to interact with Google Geocoding API.
  """

  def all_info(address, options \\ nil) do
    result = Poison.decode!(make_request(address, options).body)

    case result["status"] do
      "ZERO_RESULTS" ->
        nil

      "OVER_QUERY_LIMIT" ->
        raise GoogleGeocodingApiException, message: "You have reached your query limit"

      "REQUEST_DENIED" ->
        raise GoogleGeocodingApiException, message: "Your request was denied"

      "INVALID_REQUEST" ->
        raise GoogleGeocodingApiException, message: "Your request was invalid"

      "UNKNOWN_ERROR" ->
        raise GoogleGeocodingApiException,
          message: "Unknown error, this may succeed if you try again"

      _ ->
        result
    end
  end

  def geometry(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["geometry"]
  end

  def geo_location(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["geometry"]["location"]
  end

  def geo_location_northeast(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["geometry"]["viewport"]["northeast"]
  end

  def geo_location_southwest(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["geometry"]["viewport"]["southwest"]
  end

  def location_type(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["geometry"]["location_type"]
  end

  def formatted_address(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["formatted_address"]
  end

  def place_id(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["place_id"]
  end

  def address_components(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["address_components"]
  end

  def get_locality(address) do
    with {:ok, address_map} <- parse_address(address),
         {:ok, geometry_map} <- get_geometry(address) do
      {:ok, Map.merge(address_map, geometry_map)}
    else
      err -> err
    end
  end

  def get_region(search) do
    case all_info(search) do
      nil -> {:ok, []}
      result -> {:ok, Enum.map(Map.get(result, "results", []), &map_regions/1)}
    end
  end

  def map_regions(result) do
    location = result["geometry"]["location"]
    %{name: result["formatted_address"], latitude: location["lat"], longitude: location["lng"]}
  end

  defp get_location(country, postal) do
    result = all_info("", %{components: "country:#{country}|postal_code:#{postal}&sensor=false"})
    if result, do: List.first(result["results"])["geometry"]["location"]
  end

  defp parse_address(address) do
    case formatted_address(address) do
      nil ->
        {:error, "No results found"}

      address ->
        case String.split(address, ", ", trim: true) do
          [street, city, state_postal, country] ->
            state = String.slice(state_postal, 0..1)
            postal = String.slice(state_postal, 3..-1)

            result = %{
              address: address,
              street: street,
              city: city,
              country: country,
              state: state,
              postal: postal
            }

            {:ok, result}

          _ ->
            {:error, "No results found"}
        end
    end
  end

  def get_geometry(address) do
    case geo_location(address) do
      nil -> {:error, "No geometry found"}
      geometry -> {:ok, %{lat: geometry["lat"], lng: geometry["lng"]}}
    end
  end

  def get_coordinates(country, postal) do
    case get_location(country, postal) do
      nil -> {:error, "No geometry found"}
      geometry -> {:ok, %{lat: geometry["lat"], lng: geometry["lng"]}}
    end
  end

  def types(address) do
    result = all_info(address)
    if result, do: List.first(result["results"])["types"]
  end

  def get_by_lat_lon(lat, lon) do
    result = all_info("", %{latlng: "#{lat},#{lon}"})

    case List.first(result["results"])["formatted_address"] do
      nil ->
        {:error, "No results found"}

      address ->
        [street, city, state_postal, country] = String.split(address, ", ", trim: true)
        state = String.slice(state_postal, 0..1)
        postal = String.slice(state_postal, 3..-1)

        result = %{
          address: address,
          street: street,
          city: city,
          country: country,
          state: state,
          postal: postal
        }

        {:ok, result}
    end
  end

  defp make_request(address, params) do
    api_key = key()
    params = params || %{address: address}

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

  defp build_url(params), do: "https://maps.googleapis.com/maps/api/geocode/json?" <> params

  defp key do
    Application.get_env(:store, :google_geocoding_api)[:api_key]
  end
end
