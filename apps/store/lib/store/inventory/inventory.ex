defmodule Store.Inventory do
  @moduledoc """
  Inventory context
  """
  import Ecto.Query
  alias Store.Repo
  alias Store.Inventory.{Category, Product, PricingTier, PricingPreference, CustomerProduct}
  alias Store.{Customer, Location}
  alias Store.Utility.KeywordListToMap, as: KeywordListToMap

  def get_categories() do
    Category.get_all()
  end

  def get_product(id) do
    case Product.get(id) do
      nil -> {:error, "Product ID #{id} not found"}
      product -> {:ok, product}
    end
  end

  def get_product_for_customer(id, customer_id) do
    case Product.get(id) do
      nil ->
        {:error, "Product ID #{id} not found"}

      product ->
        product = Map.put(product, :is_favourite, CustomerProduct.is_favourite(id, customer_id))
        {:ok, product}
    end
  end

  def get_products(location_id, options) do
    case Product.get_all(location_id, options) do
      [] -> {:ok, []}
      {:error, error} -> {:error, "Cannot get Products: #{error}"}
      [locations | tail] -> {:ok, [locations | tail]}
      {:ok, locations_paged} -> {:ok, locations_paged}
    end
  end

  def get_products(options) do
    case Product.get_all(options) do
      [] -> {:ok, []}
      {:error, error} -> {:error, "Cannot get Products: #{error}"}
      [locations | tail] -> {:ok, [locations | tail]}
      {:ok, locations_paged} -> {:ok, locations_paged}
    end
  end

  def product_count(location_id) do
    case Product.get_count_by_location(location_id) do
      nil -> %{success: false, id: 0}
      count -> %{success: true, id: count}
    end
  end

  def get_products_paged(location_id, customer_id, options) do
    customer_categories = Category.get_customer_favourites(customer_id)

    Product.get_paged(
      location_id,
      customer_categories,
      %{options: options}
    )
  end

  def get_products_by_location_in_stock(location_id) do
    case Product.get_by_location_in_stock(location_id) do
      [] -> {:ok, []}
      {:error, error} -> {:error, "Cannot get Products: #{error}"}
      [locations | tail] -> {:ok, [locations | tail]}
      {:ok, l} -> {:ok, l}
    end
  end

  def save_product(product) do
    location_id = Map.get(product, :location_id)
    tier = Map.get(product, :basic_tier)
    product = Map.delete(product, :basic_tier)

    case Product.create(product) do
      {:error, error} -> {:error, "Error saving product: #{error}"}
      product -> save_product_basic_tier(product, tier, location_id)
    end
  end

  def toggle_product(product_id) do
    Product.toggle_active(product_id)
  end

  def toggle_product_stock(product_id) do
    Product.toggle_in_stock(product_id)
  end

  def save_product_basic_tier(product, tier, _bid) when is_nil(tier) do
    product
  end

  def save_product_basic_tier(product, tier, _bid) when map_size(tier) == 0 do
    product
  end

  def save_product_basic_tier(product, tier, location_id) do
    product = Enum.at(Tuple.to_list(product), 1)
    tier = Map.put(tier, :product_id, product.id)
    tier = Map.put(tier, :location_id, location_id)

    case save_pricing_tier(tier) do
      {:error, error} ->
        {:error, error}

      {:ok, basic_tier} ->
        product = Map.put(product, :basic_tier, basic_tier)
        {:ok, product}
    end
  end

  def get_pricing_preference(%{location_id: location_id}) do
    {:ok, PricingPreference.get_or_create(location_id)}
  end

  def get_pricing_preferences() do
    {:ok, PricingPreference.get_all()}
  end

  def set_pricing_preference(location_id, is_basic) do
    PricingPreference.toggle_business_preference(location_id, is_basic)
  end

  def get_pricing_tiers(location_id) do
    case PricingTier.get_all(location_id) do
      [] ->
        case save_pricing_tier(%{
               name: "Default",
               location_id: location_id
             }) do
          {:ok, tier} -> {:ok, [tier]}
          err -> err
        end

      [head | tail] ->
        {:ok, [head | tail]}
    end
  end

  def save_pricing_tier(tier) do
    case PricingTier.create(tier) do
      {:ok, tier} -> {:ok, tier}
      {:error, error} -> {:error, "Error saving tier: #{error}"}
    end
  end

  def remove_pricing_tier(args) do
    location_id = args.location_id

    case Map.has_key?(args, :move_to_tier_id) do
      false ->
        nil

      true ->
        Product.move_to_tier(args.id, args.move_to_tier_id, location_id)
    end

    case PricingTier.remove(args.id, location_id) do
      {:ok, amt} ->
        {:ok, %{success: true, id: amt}}

      {:error, _} ->
        count = Product.get_count_by_tier(args.id, location_id)
        {:ok, %{success: false, id: count}}
    end
  end

  def filter_favourite_products(customers, []), do: customers

  def filter_favourite_products(customers, nil), do: customers

  def filter_favourite_products(customers, product_ids) do
    CustomerProduct.filter_customer_ids_by_favourite_products(customers, product_ids)
  end

  def quick_glance_menu(location_id, customer_id) do
    category_ids = Category.get_customer_favourites(customer_id)
    products = Product.quick_glance(location_id)

    category_ids =
      Enum.filter(category_ids, fn id -> id in Enum.map(products, fn p -> p.category_id end) end)

    menu =
      case length(category_ids) do
        0 ->
          Enum.take(products, 3)

        1 ->
          first = Enum.filter(products, fn p -> p.category_id == Enum.at(category_ids, 0) end)
          other = Enum.filter(products, fn p -> p.category_id != Enum.at(category_ids, 0) end)

          first = Enum.take(first, 3)

          other =
            case length(first) do
              1 -> Enum.take(other, 2)
              2 -> Enum.take(other, 1)
              _ -> []
            end

          Enum.concat(first, other)

        2 ->
          first = Enum.filter(products, fn p -> p.category_id == Enum.at(category_ids, 0) end)
          second = Enum.filter(products, fn p -> p.category_id == Enum.at(category_ids, 1) end)

          other =
            Enum.filter(products, fn p ->
              p.category_id != Enum.at(category_ids, 0) and
                p.category_id != Enum.at(category_ids, 1)
            end)

          first =
            case length(first) do
              1 -> Enum.take(first, 1)
              _ -> Enum.take(first, 2)
            end

          second =
            case length(first) do
              1 -> Enum.take(second, 2)
              _ -> Enum.take(second, 1)
            end

          menu = Enum.concat(first, second)

          other =
            case length(menu) do
              2 -> Enum.take(other, 1)
              _ -> []
            end

          Enum.concat(menu, other)

        _ ->
          first = Enum.filter(products, fn p -> p.category_id == Enum.at(category_ids, 0) end)
          second = Enum.filter(products, fn p -> p.category_id == Enum.at(category_ids, 1) end)
          third = Enum.filter(products, fn p -> p.category_id == Enum.at(category_ids, 2) end)

          other =
            Enum.filter(products, fn p ->
              p.category_id != Enum.at(category_ids, 0) and
                p.category_id != Enum.at(category_ids, 1) and
                p.category_id != Enum.at(category_ids, 2)
            end)

          menu =
            [Enum.take(first, 1), Enum.take(second, 1), Enum.take(third, 1)]
            |> Enum.concat()

          other =
            case length(menu) do
              2 -> Enum.take(other, 1)
              _ -> []
            end

          Enum.concat(menu, other)
      end

    {:ok, menu}
  end

  def toggle_favourite_product(is_active, product_id, customer_id) do
    result =
      case is_active do
        true -> favourite_product(product_id, customer_id)
        false -> CustomerProduct.unfavourite(product_id, customer_id)
      end

    case result do
      {:ok, _} -> {:ok, %{success: true}}
      {:error, _} -> {:error, "There was an error toggling your favourite product."}
    end
  end

  defp favourite_product(product_id, customer_id) do
    fav_category_ids = Category.get_customer_favourites(customer_id)

    category_id =
      Product.get(product_id)
      |> Map.get(:category_id)

    case Enum.member?(fav_category_ids, category_id) do
      true -> nil
      false -> Customer.add_category_id_to_favourites(customer_id, category_id)
    end

    CustomerProduct.favourite(product_id, customer_id)
  end

  def get_customer_favourite_products(customer_id) do
    {:ok, Product.get_customer_favourite_products(customer_id)}
  end

  def product_import(location_id, products) do
    categories = Category.get_all() |> Enum.map(fn c -> %{id: c.id, name: c.name} end)

    try do
      products
      |> Enum.map(&validate_product(&1, categories))
      |> import_products(location_id)

      {:ok, %{success: true}}
    rescue
      e ->
        {:error, Map.get(e, :message, "Error importing products")}
    end
  end

  defp validate_product({product, line_number}, categories) do
    required_fields = ~w(name description image type category in_stock is_active 
    unit_price)

    case Enum.all?(required_fields, &Map.has_key?(product, &1)) do
      true ->
        with {:ok, category} <- validate_product_category(product, categories),
             {:ok, product} <- validate_product_pricing(product),
             {:ok, product} <- validate_booleans(product) do
          product
          |> Map.put("category_id", category.id)
          |> Map.drop(["category"])
        else
          {:error, msg} ->
            raise msg <> " at line # #{line_number + 1}"
        end

      false ->
        raise "CSV is missing a column."
    end
  end

  defp validate_booleans(product) do
    booleans = %{
      "is_active" => parse_boolean(product["is_active"]),
      "in_stock" => parse_boolean(product["in_stock"])
    }

    product = Map.merge(product, booleans)
    {:ok, product}
  end

  defp parse_boolean(value) do
    case value do
      "true" -> true
      "TRUE" -> true
      true -> true
      "false" -> false
      "FALSE" -> false
      false -> false
      0 -> false
      1 -> true
      "0" -> false
      "1" -> true
      _ -> true
    end
  end

  defp validate_product_pricing(product) do
    pricing = %{
      "unit_price" => parse_float(product["unit_price"])
    }

    product = Map.merge(product, pricing)
    {:ok, product}
  end

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _msg} -> float
      :error -> nil
      _ -> nil
    end
  end

  defp parse_float(value) when is_integer(value) do
    Integer.to_string(value) |> parse_float()
  end

  defp parse_float(value) do
    value
  end

  defp validate_product_category(product, categories) do
    category = product["category"]
    category_names = Enum.map(categories, fn c -> c.name end)

    case Enum.find_index(category_names, fn name -> name == category end) do
      nil ->
        {:error, "CSV has an invalid product category = #{category}"}

      index ->
        {:ok, Enum.at(categories, index)}
    end
  end

  defp import_products(products, location_id) do
    location = Location.get(location_id)
    pricing_preference = PricingPreference.get_by_location_id(location_id)
    is_basic = pricing_preference.is_basic

    products
    |> Enum.map(fn p ->
      p = Map.put(p, "location_id", location_id)

      pricing =
        Map.take(p, ~w(location_id unit_price))
        |> Map.put("is_active", true)

      product =
        case p["st"] do
          "" ->
            p

          nil ->
            p
        end

      with {:ok, product} <- Product.create(product),
           {:ok, tier} <- get_or_create_pricing_tier(product, pricing, is_basic),
           {:ok, product} <- Product.set_tier(product.id, tier.id) do
        {:ok, product}
      else
        err ->
          err
      end
    end)
  end

  defp get_or_create_pricing_tier(product, pricing, is_basic) do
    case is_basic or pricing["unit_price"] != nil do
      true ->
        pricing
        |> Map.put("product_id", product.id)
        |> PricingTier.create()

      false ->
        pricing = KeywordListToMap.convert_keyword_list_to_map(pricing)

        case PricingTier.find(pricing) do
          nil -> PricingTier.create(pricing)
          tier -> {:ok, tier}
        end
    end
  end
end
