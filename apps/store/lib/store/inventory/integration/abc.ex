defmodule Store.Inventory.Integration.Abc do
  use Tesla

  @base_url "https://api.abc.co/v0/"
  plug(Tesla.Middleware.JSON)

  def validate_api_key(client_id, api_key) do
    url = @base_url <> "clientsLocations"
    {:ok, response} = get(url, headers: [{"key", api_key}, {"clientId", client_id}])

    case response.body["data"] do
      nil -> %{success: false, locations: []}
      locations -> %{success: true, locations: map_locations(locations)}
    end
  end

  defp map_locations(locations) do
    Enum.map(locations, fn location ->
      %{
        id: location["locationId"],
        name: location["locationName"]
      }
    end)
  end

  def get_menu(%{client_id: client_id, api_key: api_key, ext_location_id: ext_location_id}) do
    url = @base_url <> "locations/#{ext_location_id}/inventory"
    {:ok, response} = get(url, headers: [{"key", api_key}, {"clientId", client_id}])
    menu_items = response.body["data"]
    map_schema(menu_items)
  end

  def map_schema(products) do
    Enum.map(products, fn product ->
      info = product["info"]
      abc = get_info(info, "abc")
      def = get_info(info, "def")

      %{
        source_id: product["productId"],
        name: product["productName"],
        # no description in abc api
        description: nil,
        image: product["productPictureURL"],
        thumb_image: product["productPictureURL"],
        type: map_type(product["category"]),
        category_id: map_category(product["category"]),
        prices: map_prices(product),
        is_active: true,
        in_stock: true,
        is_imported: false
      }
    end)
  end

  defp get_info(info, name) do
    case Enum.find(info, fn i -> i["name"] === name end) do
      nil ->
        %{amount: nil, variance: nil}

      info ->
        mid =
          case info["upperRange"] do
            nil -> 0
            upperRange -> Float.round((upperRange - info["lowerRange"]) / 2, 2)
          end

        variance = if mid == 0, do: 2, else: mid

        %{
          amount: Float.round((info["lowerRange"] + mid) / 1, 2),
          variance: variance
        }
    end
  end

  defp map_type(category) do
    case category do
      "X" -> "x"
      "Y" -> "y"
      "Z" -> "z"
      _ -> nil
    end
  end

  defp map_prices(product) do
    prices = product["weightTierInformation"]

    unit_price =
      case product["priceInMinorUnits"] do
        nil -> nil
        price -> price / 100
      end

    %{
      # doesn't exist in abc
      unit_price: unit_price
    }
  end

  defp get_price(prices, unit) do
    case Enum.find(prices, fn p -> p["name"] == unit end) do
      nil -> nil
      price -> price["pricePerUnitInMinorUnits"] / 100
    end
  end

  defp map_category(category) do
    case category do
      "A" ->
        1

      "B" ->
        1

      "C" ->
        1

      "D" ->
        2

      "E" ->
        2

      "F" ->
        3

      "G" ->
        4

      "H" ->
        5

      "I" ->
        7

      "J" ->
        9

      # we are going to need to add these categories or products will not come across
      # "Gear" -> 10,
      # "Hardware",
      # "Other"
      _ ->
        nil
    end
  end
end
