defmodule Store.Inventory.Integration.Xyz do
  use Tesla

  @base_url "https://api.xyz.com/api/web/v1/menu_items"
  plug(Tesla.Middleware.JSON)

  def validate_api_key(api_key) do
    {:ok, response} = get(@base_url, query: [api_key: api_key])

    case response.body["data"] do
      nil -> %{success: false}
      _ -> %{success: true}
    end
  end

  def get_menu(api_key) do
    {:ok, response} = get(@base_url, query: [api_key: api_key])
    menu_items = response.body["data"]
    map_schema(menu_items)
  end

  def map_schema(products) do
    Enum.map(products, fn product ->
      attrs = product["attributes"]

      %{
        source_id: product["id"],
        name: attrs["name"],
        description: strip_html(attrs["body"]),
        image: map_image(attrs["image_url"]),
        thumb_image: map_image(attrs["thumb_image_url"]),
        type: map_type(attrs["category_name"]),
        is_active: attrs["published"],
        category_id: map_category(attrs["category_name"]),
        # treat published as the in_stock identifier
        in_stock: attrs["published"],
        prices: map_prices(attrs["prices"]),
        is_imported: false
      }
    end)
  end

  defp strip_html(description) do
    HtmlSanitizeEx.strip_tags(description)
  end

  defp map_image(image) do
    case image do
      nil ->
        nil

      img ->
        case String.contains?(img, "image_missing.jpg") do
          true -> nil
          false -> img
        end
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

  defp map_prices(prices) do
    %{
      unit_price: prices["unit"]
    }
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

      "D" ->
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
