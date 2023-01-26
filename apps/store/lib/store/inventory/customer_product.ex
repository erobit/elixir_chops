defmodule Store.Inventory.CustomerProduct do
  use Store.Model

  schema "customer_products" do
    belongs_to(:customer, Store.Customer)
    belongs_to(:product, Store.Inventory.Product)
    field(:is_active, :boolean, default: true)
    timestamps(type: :utc_datetime)
  end

  def favourite(product_id, customer_id) do
    customer_product =
      CustomerProduct
      |> Repo.get_by(product_id: product_id, customer_id: customer_id)

    case customer_product do
      nil ->
        %CustomerProduct{}
        |> change(%{product_id: product_id, customer_id: customer_id})
        |> Repo.insert()

      _ ->
        customer_product
        |> change(is_active: true)
        |> Repo.update()
    end
  end

  def unfavourite(product_id, customer_id) do
    CustomerProduct
    |> Repo.get_by(product_id: product_id, customer_id: customer_id)
    |> change(is_active: false)
    |> Repo.update()
  end

  def is_favourite(product_id, customer_id) do
    customer_product =
      CustomerProduct
      |> Repo.get_by(product_id: product_id, customer_id: customer_id)

    case customer_product do
      nil -> false
      _ -> Map.get(customer_product, :is_active)
    end
  end

  def get_customer_product_ids_by_categories(customer_id, category_ids) do
    from(cp in CustomerProduct,
      join: p in assoc(cp, :product),
      where: p.category_id in ^category_ids and cp.is_active and cp.customer_id == ^customer_id,
      select: %{
        id: p.id
      }
    )
    |> Repo.all()
    |> Enum.map(fn p -> p.id end)
  end

  def unfavourite_product_ids_for_customer(customer_id, product_ids) do
    from(cp in CustomerProduct,
      where: cp.product_id in ^product_ids and cp.is_active and cp.customer_id == ^customer_id
    )
    |> Repo.update_all(set: [is_active: false])
  end

  def filter_customer_ids_by_favourite_products(customers, product_ids) do
    customer_ids = Enum.map(customers, fn c -> c.id end)

    customer_ids =
      from(cp in CustomerProduct,
        where: cp.customer_id in ^customer_ids and cp.product_id in ^product_ids and cp.is_active,
        distinct: cp.customer_id,
        select: %{
          id: cp.customer_id
        }
      )
      |> Repo.all()
      |> Enum.map(fn cp -> cp.id end)

    Enum.filter(customers, fn c -> Enum.member?(customer_ids, c.id) end)
  end

  def delete_all(product_ids) when is_list(product_ids) do
    from(cp in CustomerProduct, where: cp.product_id in ^product_ids)
    |> Repo.delete_all()
  end
end
