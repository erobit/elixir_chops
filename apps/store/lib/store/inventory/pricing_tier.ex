defmodule Store.Inventory.PricingTier do
  use Store.Model

  schema "pricing_tiers" do
    field(:name, :string)
    field(:is_active, :boolean, default: true)
    field(:unit_price, :float)
    belongs_to(:product, Store.Inventory.Product)
    belongs_to(:location, Store.Location)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def insert(struct) do
    %PricingTier{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def find(%{
        location_id: location_id,
        unit_price: nil
      }) do
    from(p in PricingTier,
      where:
        p.location_id == ^location_id and is_nil(p.product_id),
      limit: 1
    )
    |> Repo.one()
  end

  def find(%{
        location_id: location_id,
        unit_price: unit_price
      }) do
    from(p in PricingTier,
      where:
        p.location_id == ^location_id and not is_nil(p.product_id) and p.unit_price == ^unit_price,
      limit: 1
    )
    |> Repo.one()
  end

  def delete_all(product_ids) when is_list(product_ids) do
    from(p in PricingTier, where: p.product_id in ^product_ids)
    |> Repo.delete_all()
  end

  def delete_all(location_id) do
    from(p in PricingTier, where: p.location_id == ^location_id)
    |> Repo.delete_all()
  end

  def null_all_product_ids(product_ids) when is_list(product_ids) do
    from(p in PricingTier, where: p.product_id in ^product_ids)
    |> Repo.update_all(set: [product_id: nil])
  end

  def update(struct) do
    PricingTier
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  def remove(id, location_id) do
    try do
      result =
        from(pt in PricingTier,
          where: pt.location_id == ^location_id and pt.id == ^id
        )
        |> Repo.delete_all()

      {:ok, Enum.at(Tuple.to_list(result), 0)}
    rescue
      _e -> {:error, "Constraint Error"}
    end
  end

  def get_all(location_id) do
    PricingTier
    |> where([pt], pt.location_id == ^location_id)
    |> where([pt], is_nil(pt.product_id))
    |> Repo.all()
  end

  def changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(name unit_price product_id location_id is_active)a
    )
    |> validate_required(~w(location_id)a)
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:product_id)
  end
end
