defmodule StoreAPI.Web.ShopView do
  use StoreAPI.Web, :view

  def render("index.json", %{shops: shops}) do
    Enum.map(shops, &shop_json/1)
  end

  defp shop_json(shop) do
    %{
      id: shop.id,
      name: shop.name,
      address: shop.address,
      city: shop.city,
      province: shop.province,
      postal_code: shop.postal_code,
      phone: shop.phone,
      hero: shop.hero,
      logo: shop.logo,
      is_active: shop.is_active,
      created: shop.inserted_at,
      updated: shop.updated_at
    }
  end
end
