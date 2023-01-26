defmodule Store.Business do
  use Store.Model

  @business_types ~w(store headshop)

  schema "businesses" do
    field(:type, :string)
    field(:name, :string)
    field(:subdomain, :string)
    field(:country, :string)
    field(:is_verified, :boolean)
    field(:is_active, :boolean)
    field(:language, :string, default: "en-us")
    has_many(:locations, Store.Location)
    timestamps(type: :utc_datetime)
  end

  def get(id) do
    Business
    |> Repo.get(id)
  end

  def get_all(options) do
    Business
    |> order_by([b], desc: b.inserted_at)
    |> search(options)
    |> sort(options)
    |> filter(options)
    |> paginate(options)
  end

  def get_by_subdomain(subdomain) do
    Business
    |> Repo.get_by(subdomain: String.downcase(subdomain), is_active: true)
  end

  def get_by_location_id(location_id) do
    from(b in Business,
      join: l in assoc(b, :locations),
      where: l.id == ^location_id,
      select: %{
        id: b.id
      }
    )
    |> Repo.one()
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  @doc """
  Builds a changeset based on 'struct' and 'params'
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(type country name subdomain language is_verified is_active)a)
    |> validate_required(~w(type subdomain is_verified)a)
    |> validate_inclusion(:type, @business_types)
    |> unique_constraint(:subdomain)
    |> downcase_subdomain()
  end

  def downcase_subdomain(changeset) do
    update_change(changeset, :subdomain, &String.downcase/1)
  end

  def toggle_active(id, is_active) do
    Business
    |> Repo.get(id)
    |> change(%{is_active: is_active})
    |> Repo.update()
  end

  defp filter(query, %{options: %{filters: filters}}) do
    # @TODO should we add an is_active boolean to businesses so we can disable them?
    country_filter = find_filter(filters, "country")
    type_filter = find_filter(filters, "type")
    active_filter = find_filter(filters, "is_active")

    query
    |> filter_by_country(country_filter)
    |> filter_by_type(type_filter)
    |> filter_active(active_filter)
  end

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_by_type(query, nil), do: query

  defp filter_by_type(query, %{args: args}) do
    from(b in query,
      where: b.type == ^Enum.at(args, 0)
    )
  end

  defp filter_active(query, nil), do: query

  defp filter_active(query, %{args: args}) do
    case args do
      ["true"] -> from(b in query, where: b.is_active)
      ["false"] -> from(b in query, where: not b.is_active)
      _ -> query
    end
  end

  defp filter_by_country(query, nil), do: query

  defp filter_by_country(query, %{args: args, field: _}) do
    from(b in query,
      where: b.country == ^Enum.at(args, 0)
    )
  end

  defp search(query, %{options: %{search: name}}) do
    query
    |> where([b], ilike(b.subdomain, ^"%#{name}%"))
    |> or_where([b], ilike(b.name, ^"%#{name}%"))
  end

  defp search(query, _options), do: query

  defp sort(query, %{options: %{sort: %{field: fieldname, order: order}}}) do
    direction = if order == 1, do: :asc, else: :desc
    query |> order_by([b], [{^direction, field(b, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _options), do: query

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(queryset, _options) do
    queryset
    |> Repo.all()
  end

  defp insert(struct) do
    %Business{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Business
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end
end
