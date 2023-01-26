defmodule Homescreen.HomescreenController do
  use StoreAPI.Web, :controller

  def index(conn, _params) do
    shop = Store.Location.get(conn.params["id"])

    render(conn, "homescreen.html", %{
      name: shop.name,
      logo: shop.logo
    })
  end
end

defmodule StoreAPI.Web.LayoutView do
  use StoreAPI.Web, :view
end
