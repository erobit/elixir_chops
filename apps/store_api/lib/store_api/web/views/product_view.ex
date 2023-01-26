defmodule StoreAPI.Web.ProductView do
  use StoreAPI.Web, :view

  def render("index.json", %{products: products, preferences: preferences}) do
    Enum.map(products, fn product -> product_json(product, preferences) end)
  end

  defp product_json(product, preferences) do
    %{
      id: product.id,
      name: product.name,
      description: product.description,
      image: product.image,
      type: product.type,
      location: format_location(product.location),
      category: format_category(product.category),
      pricing: format_pricing(product, preferences),
      is_active: product.is_active,
      in_stock: product.in_stock,
      created: product.inserted_at,
      updated: product.updated_at
    }
  end

  defp format_category(category) do
    category |> Map.take([:id, :name])
  end

  defp format_location(location) do
    location |> Map.take([:id, :name])
  end

  defp format_pricing(product, preferences) do
    preference =
      Enum.find(
        preferences,
        %{is_basic: true},
        fn pref -> pref.location_id == product.location_id end
      )

    default = %{
      name: nil,
      gram: nil,
      ounce: nil,
      unit_price: nil,
      tier_id: nil
    }

    product =
      if product.basic_tier == nil do
        Map.put(product, :basic_tier, default)
      else
        product
      end

    product =
      if product.tier == nil do
        Map.put(product, :tier, default)
      else
        product
      end

    pricing =
      case preference.is_basic do
        true ->
          Map.get(product, :basic_tier, default)
          |> Map.put(:type, "basic")

        false ->
          Map.get(product, :tier, default)
          |> Map.put(:type, "tier")
      end

    Map.take(pricing, [
      :type,
      :name,
      :unit_price
    ])
    |> Map.put(:tier_id, product.tier_id)
  end
end
