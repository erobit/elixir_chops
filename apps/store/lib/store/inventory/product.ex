defmodule Store.Inventory.Product do
  use Store.Model

  schema "products" do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:image, :string)
    field(:type, :string)
    field(:is_active, :boolean)
    field(:in_stock, :boolean)
    field(:is_favourite, :boolean, virtual: true)
    belongs_to(:location, Store.Location)
    belongs_to(:category, Store.Inventory.Category)
    belongs_to(:tier, Store.Inventory.PricingTier)
    has_many(:customer_products, Store.Inventory.CustomerProduct, where: [is_active: true])
    has_one(:basic_tier, Store.Inventory.PricingTier, on_delete: :delete_all)

    has_one(:preference, Store.Inventory.PricingPreference,
      foreign_key: :location_id,
      references: :location_id
    )

    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def get(id) do
    Product
    |> preload(:category)
    |> preload(:basic_tier)
    |> preload(:tier)
    |> preload(:location)
    |> Repo.get(id)
  end

  defp by_location(query, nil) do
    from(p in query,
      join: l in assoc(p, :location),
      join: b in assoc(l, :business),
      where: l.is_active and b.is_active
    )
  end

  defp by_location(query, location_id) do
    from(p in query,
      join: l in assoc(p, :location),
      join: b in assoc(l, :business),
      where: l.is_active and b.is_active and l.id == ^location_id
    )
  end

  def get_paged(location_id, customer_categories, options) do
    from(p in Product,
      where: p.is_active
    )
    |> by_location(location_id)
    |> preload(:category)
    |> preload(:basic_tier)
    |> preload(:tier)
    |> preload(:preference)
    |> preload(:location)
    |> filter(options)
    |> search(options)
    |> sort_by_preference(customer_categories, options)
    |> paginate(options)
  end

  def get_all(location_id, options) do
    from(p in Product, where: p.location_id == ^location_id)
    |> preload(:location)
    |> preload(:category)
    |> preload(:basic_tier)
    |> filter(options)
    |> search(options)
    |> sort(options)
    |> paginate(options)
  end

  def get_for_export(location_id) do
    from(p in Product, where: p.location_id == ^location_id)
    |> preload(:basic_tier)
    |> preload(:category)
    |> preload(:tier)
    |> Repo.all()
  end

  def get_count_by_location(location_id) do
    from(p in Product, where: p.location_id == ^location_id)
    |> Repo.aggregate(:count, :id)
  end

  def get_all(options) do
    from(p in Product)
    |> preload(:location)
    |> preload(:category)
    |> preload(:basic_tier)
    |> preload(:tier)
    |> filter(options)
    |> search(options)
    |> sort(options)
    |> paginate(options)
  end

  def delete_all(location_id) do
    from(p in Product, where: p.location_id == ^location_id)
    |> Repo.delete_all()
  end

  def delete_all(ids, source_field) do
    from(p in Product, where: field(p, ^source_field) in ^ids)
    |> Repo.delete_all()
  end

  def null_all_tier_ids(product_ids) when is_list(product_ids) do
    from(p in Product, where: p.id in ^product_ids)
    |> Repo.update_all(set: [tier_id: nil])
  end

  def quick_glance(location_id) do
    from(p in Product,
      where: p.location_id == ^location_id and p.is_active and p.in_stock,
      order_by: [p.category_id, p.name]
    )
    |> preload(:category)
    |> preload(:basic_tier)
    |> preload(:tier)
    |> Repo.all()
  end

  def get_by_location_in_stock(location_id) do
    from(
      p in Product,
      where: p.location_id == ^location_id and p.is_active and p.in_stock
    )
    |> preload(:location)
    |> preload(:category)
    |> preload(:basic_tier)
    |> preload(:tier)
    |> Repo.all()
  end

  def get_count_by_tier(tier_id, location_id) do
    from(p in Product,
      where: p.tier_id == ^tier_id and p.location_id == ^location_id,
      select: count(p.id)
    )
    |> Repo.one()
  end

  def move_to_tier(from_tier, to_tier, location_id) do
    from(p in Product,
      where: p.location_id == ^location_id and p.tier_id == ^from_tier,
      update: [set: [tier_id: ^to_tier]]
    )
    |> Repo.update_all([])
  end

  def get_products(params) do
    product_ids = Map.get(params, :products, [])

    from(p in Product, where: p.id in ^product_ids)
    |> Repo.all()
  end

  def get_customer_favourite_products(customer_id) do
    from(p in Product,
      join: cp in assoc(p, :customer_products),
      join: c in assoc(p, :category),
      join: l in assoc(p, :location),
      where: cp.customer_id == ^customer_id,
      order_by: [asc: c.id, asc: p.name],
      select: %{
        id: p.id,
        name: p.name,
        category: c,
        location: l,
        is_favourite: cp.is_active
      }
    )
    |> Repo.all()
  end

  def toggle_active(id) do
    product =
      from(p in Product,
        where: p.id == ^id
      )
      |> Repo.one()

    change(product, %{is_active: not product.is_active})
    |> Repo.update()
  end

  def toggle_in_stock(id) do
    product =
      from(p in Product,
        where: p.id == ^id
      )
      |> Repo.one()

    change(product, %{in_stock: not product.in_stock})
    |> Repo.update()
  end

  def set_tier(product_id, tier_id) do
    Product
    |> Repo.get(product_id)
    |> change(%{tier_id: tier_id})
    |> Repo.update()
  end

  defp filter(query, %{options: %{filters: filters}}) do
    category_filter = find_filter(filters, "category_id")
    type_filter = find_filter(filters, "type")
    location_radius_filter = find_filter(filters, "location_radius")

    query
    |> filter_categories(category_filter)
    |> filter_types(type_filter)
    |> filter_location_radius(location_radius_filter)
  end

  defp filter(query, _options), do: query

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_categories(query, nil), do: query

  defp filter_categories(query, %{args: args}) do
    ids = Enum.map(args, &String.to_integer/1)

    from(p in query,
      join: c in assoc(p, :category),
      where: c.id in ^ids
    )
  end

  defp filter_types(query, nil), do: query

  defp filter_types(query, %{args: args}) do
    from(p in query,
      where: p.type in ^args
    )
  end

  defp filter_location_radius(query, nil), do: query

  defp filter_location_radius(query, %{args: args}) do
    [lat, lng, radius] =
      args
      |> Enum.map(&Float.parse/1)
      |> Enum.map(fn {c, _i} -> c end)

    from(p in query,
      join: l in assoc(p, :location),
      where:
        fragment(
          "ST_DWithin(?::geography, ST_SetSRID(ST_MakePoint(?, ?), ?), ?)",
          l.point,
          ^lng,
          ^lat,
          4326,
          ^radius
        )
    )
  end

  defp sort(query, %{options: %{sort: %{field: "category_name", order: order}}}) do
    direction = if order == 1, do: :asc, else: :desc

    from(p in query,
      join: c in assoc(p, :category),
      order_by: [{^direction, c.name}]
    )
  end

  defp sort(query, %{options: %{sort: %{field: fieldname, order: order}}}) do
    direction = if order == 1, do: :asc, else: :desc
    query |> order_by([d], [{^direction, field(d, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _options) do
    from(p in query, order_by: [asc: p.name])
  end

  # Sort by preference and price
  defp sort_by_preference(query, customer_categories, %{
         options: %{sort: %{field: _field, order: order}}
       }) do
    direction = if order == 1, do: :asc, else: :desc

    from(p in query,
      join: c in assoc(p, :category),
      join: t in assoc(p, :tier),
      join: bt in assoc(p, :basic_tier),
      join: pp in assoc(p, :preference),
      order_by: [
        {:desc, c.id in ^customer_categories},
        {:asc, c.id},
        {^direction,
         fragment(
           "CASE WHEN ? NOT IN (?,?) THEN ? ELSE ? END",
           c.id,
           1,
           2,
           bt.unit_price,
           fragment("CASE WHEN ? THEN ? ELSE ? END", pp.is_basic, bt.gram, t.gram)
         )}
      ]
    )
  end

  # Sort by preference
  defp sort_by_preference(query, customer_categories, %{options: %{sort: _}}) do
    from(p in query,
      join: c in assoc(p, :category),
      order_by: [desc: c.id in ^customer_categories, asc: c.id]
    )
  end

  defp search(query, %{options: %{search: nil}}), do: query

  defp search(query, %{options: %{search: name}}) do
    from(p in query,
      join: c in assoc(p, :category),
      where: ilike(p.name, ^"%#{name}%") or ilike(c.name, ^"%#{name}%")
    )
  end

  defp search(query, _options), do: query

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(query, _options), do: query |> Repo.all()

  defp insert(struct) do
    %Product{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Product
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  def changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(name description image type is_active location_id 
      category_id tier_id sync_item_id)a
    )
    |> validate_required(~w(location_id category_id)a)
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:category_id)
  end

  # only used on custom customer paged object
  defimpl CSV.Encode, for: Product do
    def encode(p, env \\ []) do
      [
        p.name,
        p.description,
        p.image,
        p.type,
        p.category,
        p.in_stock,
        p.is_active,
        p.unit_price
      ]
      |> Enum.map(fn v -> CSV.Encode.encode(v, env) end)
      |> Enum.join(",")
    end
  end
end
