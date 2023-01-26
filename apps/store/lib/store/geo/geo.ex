defmodule Store.Geo do
  @moduledoc """
  Geo context

  `Geo` is used by the store context when operating on geo related entities.
  """
  alias Store.Geo.{Geometry, Timezone, Geocode}

  def set_point(struct) do
    Geometry.set_point(struct)
  end

  def set_polygon(struct) do
    Geometry.set_polygon(struct)
  end

  def set_timezone(struct) do
    %Geo.Point{coordinates: {lon, lat}} = struct.point

    case Timezone.get_by_lat_lon(lat, lon) do
      {:ok, timezone} -> Map.put(struct, :timezone, timezone)
      _ -> struct
    end
  end

  def get_locality(address) do
    Geocode.get_locality(address)
  end

  def get_by_lat_lon(lat, lon) do
    Geocode.get_by_lat_lon(lat, lon)
  end

  def get_coordinates(code) do
    country_code =
      case String.length(code) == 6 do
        true -> "CA"
        false -> "US"
      end

    Geocode.get_coordinates(country_code, code)
  end

  def get_region(search) do
    Geocode.get_region(search)
  end

  def get_geo_ip(ip) do
    Store.Geo.Ip.locate(ip)
  end
end
