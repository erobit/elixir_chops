defmodule Store.Geo.GeocodeFake do
  @moduledoc """
  Fake implementation for the Store.Geocodeer
  """

  @address %{
    address: "221B",
    street: "Baker St",
    city: "Marylebone",
    country: "England",
    state: "UK",
    postal: "NW1 6XE"
  }
  @lat_lng %{lat: 47.319636, lng: 5.035495}

  def get_geometry("nil, nil"), do: {:ok, %{lat: nil, lng: nil}}

  def get_geometry(_address) do
    {:ok, @lat_lng}
  end

  def get_by_lat_lon(_lat, _lon) do
    @address
  end

  def get_coordinates(_country, _postal) do
    {:ok, @lat_lng}
  end

  def get_locality(_address) do
    {:ok, Map.merge(@address, @lat_lng)}
  end

  def get_region(_search) do
    {:ok, [%{name: @address.city, latitude: @lat_lng.lat, longitude: @lat_lng.lng}]}
  end
end
