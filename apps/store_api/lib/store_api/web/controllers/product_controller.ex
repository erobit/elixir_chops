defmodule StoreAPI.Web.ProductController do
  use StoreAPI.Web, :controller

  def index(conn, _params) do
    # query by shop_id or return all products
    # Note: this will get wonky because of duplicates
    # It's not like supplier LP inventory which should be a unique
    # source of truth

    {:ok, pricing_prefs} = Store.Inventory.get_pricing_preferences()

    {:ok, products} =
      case conn.params["shop_id"] do
        nil -> Store.Inventory.get_products(nil)
        id -> Store.Inventory.get_products_by_location_in_stock(id)
      end

    render(conn, "index.json", products: products, preferences: pricing_prefs)
  end
end
