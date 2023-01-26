defmodule Store.Inventory.Integration.ProductSyncItem do
  use Store.Model

  schema "product_sync_items" do
    field(:platform_id, :integer)
    field(:source_id, :integer)
    field(:name, :string, null: false)
    field(:description, :string)
    field(:image, :string)
    field(:thumb_image, :string)
    field(:type, :string)
    field(:is_active, :boolean)
    field(:in_stock, :boolean)
    field(:is_imported, :boolean)
    field(:prices, :map)
    belongs_to(:product_integration, Store.Inventory.Integration.ProductIntegration)
    belongs_to(:category, Store.Inventory.Category)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def get(id) do
    ProductSyncItem
    |> preload(:category)
    |> Repo.get(id)
  end

  def get_all(location_id, options) do
    from(p in ProductSyncItem,
      join: i in assoc(p, :product_integration),
      where: i.location_id == ^location_id,
      order_by: [
        desc: p.is_active,
        desc: p.in_stock,
        asc: p.category_id,
        asc: p.type,
        asc: p.name
      ]
    )
    |> preload(:category)
    |> filter(options)
    |> search(options)
    |> paginate(options)
  end

  def get_all_not_imported(location_id, options) do
    from(p in ProductSyncItem,
      join: i in assoc(p, :product_integration),
      where: i.location_id == ^location_id and p.is_imported == false,
      order_by: [
        desc: p.is_active,
        desc: p.in_stock,
        asc: p.category_id,
        asc: p.type,
        asc: p.name
      ]
    )
    |> preload(:category)
    |> filter(options)
    |> search(options)
    |> paginate(options)
  end

  def delete_by_location(location_id) do
    from(p in ProductSyncItem,
      join: i in assoc(p, :product_integration),
      where: i.location_id == ^location_id
    )
    |> Repo.delete_all()
  end

  def delete_all(ids, location_id, source_field) do
    from(p in ProductSyncItem,
      join: i in assoc(p, :product_integration),
      where: field(p, ^source_field) in ^ids and i.location_id == ^location_id
    )
    |> Repo.delete_all()
  end

  def import(id) do
    item =
      from(p in ProductSyncItem,
        where: p.id == ^id
      )
      |> Repo.one()

    change(item, %{is_active: not item.is_active})
    |> Repo.update()
  end

  defp filter(query, %{options: %{filters: filters}}) do
    category_filter = find_filter(filters, "category_id")
    type_filter = find_filter(filters, "type")

    query
    |> filter_categories(category_filter)
    |> filter_types(type_filter)
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

  defp sort(query, _options), do: query

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
    %ProductSyncItem{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def update(struct) do
    ProductSyncItem
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  def changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(platform_id source_id name description product_integration_id
      image thumb_image type prices is_active category_id in_stock is_imported
      )a
    )
    |> validate_required(~w(name)a)
  end
end
