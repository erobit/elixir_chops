defmodule Store.Geo.Geometry do
  @geocode_api Application.get_env(:store, :geocoder)

  @doc """
    Set the (GeoJSON) polygon geometry for a provided struct with polygon coordinates and type

    ## Examples

      iex> Store.Geo.Geometry.set_polygon(%{})
      %{}

      iex> Store.Geo.Geometry.set_polygon(%{polygon: %{coordinates: nil}})
      %{polygon: %{coordinates: nil}}

      iex> Store.Geo.Geometry.set_polygon(%{polygon: %{coordinates: [[[-123.03181715099561, 49.23251421814713]]], type: "Polygon"}})
      %{polygon: %Geo.Polygon{coordinates: [[{-123.03181715099561, 49.23251421814713}]], properties: %{}, srid: 4326}}
  """
  def set_polygon(struct) do
    if Map.has_key?(struct, :polygon) do
      if struct.polygon.coordinates != nil do
        polygon = %{"coordinates" => struct.polygon.coordinates, "type" => struct.polygon.type}
        polygon = Geo.JSON.decode!(polygon)
        polygon = Map.put(polygon, :srid, 4326)
        Map.put(struct, :polygon, polygon)
      else
        struct
      end
    else
      struct
    end
  end

  @doc """
    Set the (GeoJSON) point geometry for a provided address and postal code

    @TODO Note: we may need more fidelity, reason why I wanted country here
    we could add a virtual full address field and send it from the front end
    which would allow us more fidelity when performing this geocode lookup

    ## Examples

      iex> Store.Geo.Geometry.set_point(%{address: "nil", postal_code: "nil"})
      %{address: "nil", postal_code: "nil", point: nil}

      iex> Store.Geo.Geometry.set_point(%{address: "221B Baker Street", postal_code: "NW1 6XE"})
      %{
        address: "221B Baker Street",
        point: %Geo.Point{
          coordinates: {5.035495, 47.319636},
          properties: %{},
          srid: 4326
        },
        postal_code: "NW1 6XE"
      }
  """
  def set_point(struct) do
    address = "#{struct.address}, #{struct.postal_code}"
    {:ok, geo} = @geocode_api.get_geometry(address)

    point =
      case geo do
        %{lat: nil, lng: nil} ->
          nil

        %{lat: lat, lng: lng} ->
          %Geo.Point{coordinates: {lng, lat}, srid: 4326}
      end

    Map.put(struct, :point, point)
  end
end
