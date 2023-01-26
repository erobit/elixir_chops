defmodule CrmProducts.Csv.Plug do
  alias Store
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    employee = conn.private[:absinthe][:context][:employee]

    case conn.params["location_id"] do
      nil ->
        conn |> send_resp(400, Poison.encode!(%{message: "location_id required"}))

      location_id ->
        is_location_member = Store.employee_member_of_location?(employee, location_id)

        if is_location_member do
          fields = ~w(name description image type category in_stock is_active 
          unit_price)

          products = Store.Inventory.Product.get_for_export(location_id)

          csv_content =
            products
            |> Enum.map(fn p ->
              p =
                normalize_fields(p)
                |> Map.take(Enum.map(fields, &String.to_atom/1))

              Map.merge(%Store.Inventory.Product{}, p)
            end)
            |> Enum.map(fn m -> [m] end)
            |> CSV.encode()
            |> Enum.to_list()

          head = Enum.join(fields, ",") <> "\r\n"
          csv = [head | csv_content]

          filename = "platform-products-#{location_id}"

          conn
          |> put_resp_content_type("text/csv")
          |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
          |> send_resp(200, csv)
        else
          conn |> send_resp(400, Poison.encode!(%{message: "Unauthorized"}))
        end
    end
  end

  defp normalize_fields(product) do
    product
    |> normalize_categories()
    |> normalize_pricing_tiers()
  end

  defp normalize_categories(product) do
    product |> Map.put(:category, product.category.name)
  end


  defp normalize_pricing_tiers(product) do
    tier =
      case product.basic_tier do
        nil -> product.tier
        basic_tier -> basic_tier
      end

    normalize_tier(product, tier)
  end

  defp normalize_tier(product, tier) do
    product
    |> Map.merge(%{
      unit_price: tier.unit_price
    })
  end
end
