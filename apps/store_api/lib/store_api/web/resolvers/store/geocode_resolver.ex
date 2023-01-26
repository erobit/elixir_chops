defmodule StoreAPI.Resolvers.Geocode do
  alias Store.Geo

  def get_locality(_parent, params, %{context: %{employee: _employee}}) do
    case Geo.get_locality(params.address) do
      {:error, error} -> {:error, error}
      {:ok, locality} -> {:ok, locality}
    end
  end

  def get_region(%{search: search}, %{context: %{customer: _customer}}) do
    case Geo.get_region(search) do
      {:error, error} -> {:error, error}
      {:ok, results} -> {:ok, results}
    end
  end

  def get_coordinates(%{code: code}, %{context: %{customer: _customer}}) do
    case Geo.get_coordinates(code) do
      {:error, error} -> {:error, error}
      {:ok, coordinates} -> {:ok, coordinates}
    end
  end

  def get_by_lat_lon(%{lat: lat, lon: lon}, %{context: %{customer: _customer}}) do
    case Geo.get_by_lat_lon(lat, lon) do
      {:error, error} -> {:error, error}
      {:ok, locality} -> {:ok, locality}
    end
  end

  def ip(_, %{context: %{ip: ip}}) do
    case Geo.get_geo_ip(ip) do
      {:error, error} -> {:error, error}
      {:ok, result} -> {:ok, result}
    end
  end

  def provinces(%{country_code: country_code}, %{context: %{employee: _employee}}) do
    result =
      Application.app_dir(:store_api, "priv/data/provinces.json")
      |> File.read!()
      |> Poison.decode!(as: :province)
      |> Enum.filter(&(&1["country"] == country_code))
      |> Enum.map(fn record ->
        for {key, val} <- record, into: %{}, do: {String.to_atom(key), val}
      end)

    {:ok, result}
  end
end
