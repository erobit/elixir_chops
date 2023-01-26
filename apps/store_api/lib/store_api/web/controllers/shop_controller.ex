defmodule StoreAPI.Web.ShopController do
  use StoreAPI.Web, :controller

  def index(conn, _params) do
    opts = %{options: %{filters: []}}
    filter = opts |> filter_by_active(conn.params["is_active"])
    shops = Store.get_locations(filter)
    render(conn, "index.json", shops: shops)
  end

  defp filter_by_active(opts, is_active) do
    case is_active do
      nil -> opts
      "0" -> add_filter_is_active(opts, "false")
      "1" -> add_filter_is_active(opts, "true")
      "true" -> add_filter_is_active(opts, "true")
      "false" -> add_filter_is_active(opts, "false")
      _ -> opts
    end
  end

  defp add_filter_is_active(opts, is_active) do
    filters = opts.options.filters ++ [%{field: "is_active", args: [is_active]}]
    put_in(opts.options.filters, filters)
  end
end
