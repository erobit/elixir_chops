defmodule Store.Loyalty.Deal do
  use Store.Model

  @frequency_types ~w(single-use daily)
  def frequency_types, do: @frequency_types

  @default_days_of_week [
    %{weekday: "mon", active: true},
    %{weekday: "tue", active: true},
    %{weekday: "wed", active: true},
    %{weekday: "thu", active: true},
    %{weekday: "fri", active: true},
    %{weekday: "sat", active: true},
    %{weekday: "sun", active: true}
  ]
  def default_days_of_week, do: @default_days_of_week

  schema "deals" do
    field(:name, :string)
    field(:start_time, :time)
    field(:end_time, :time)
    field(:expiry, ConvertUTCDateTime)
    field(:is_active, :boolean)
    field(:frequency_type, :string)
    field(:claims, :integer, virtual: true, default: 0)
    belongs_to(:business, Store.Business)
    belongs_to(:location, Store.Location)
    embeds_many(:days_of_week, DaysOfWeek, on_replace: :delete)

    many_to_many(:categories, Store.Inventory.Category,
      join_through: "deals_categories",
      on_replace: :delete
    )

    timestamps(type: :utc_datetime)
  end

  def get(id) do
    Deal
    |> preload(:categories)
    |> preload(:location)
    |> Repo.get(id)
  end

  def get_active_deal(id) do
    case Repo.get_by(Deal, id: id, is_active: true) do
      nil -> {:error, "Deal is not active"}
      deal -> {:ok, deal}
    end
  end

  def get_all(business_id, location_id, options) do
    Deal
    |> filter(options)
    |> where([d], d.location_id == ^location_id)
    |> where([d], d.business_id == ^business_id)
    |> search(options)
    |> sort(options)
    # always sort by name secondary as expiry doesn't include time
    |> order_by([d], d.name)
    |> paginate(options)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def toggle_active(id, is_active) do
    Deal
    |> Repo.get(id)
    |> change(%{is_active: is_active})
    |> Repo.update()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      ~w(business_id name start_time end_time frequency_type expiry is_active location_id)a
    )
    |> put_assoc(:categories, Category.get_categories(params))
    |> put_embed(:days_of_week, parse_days(params))
    |> validate_required(~w(business_id name categories location_id)a)
    |> validate_inclusion(:frequency_type, @frequency_types)
    |> foreign_key_constraint(:business_id)
  end

  defp parse_days(params) do
    Map.get(params, :days_of_week, @default_days_of_week)
    |> Enum.map(&DaysOfWeek.create/1)
  end

  defp search(query, %{options: %{search: name}}) do
    query |> where([d], ilike(d.name, ^"%#{name}%"))
  end

  defp search(query, _options), do: query

  defp sort(query, %{options: %{sort: %{field: fieldname, order: order}}}) do
    direction = if order == 1, do: :asc, else: :desc
    query |> order_by([d], [{^direction, field(d, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _options), do: query

  defp filter(query, %{options: %{filters: filters}}) do
    category_filter = find_filter(filters, "category_id")
    active_filter = find_filter(filters, "is_active")

    query
    |> filter_categories(category_filter)
    |> filter_active(active_filter)
  end

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_categories(query, nil), do: query

  defp filter_categories(query, %{args: args, field: _}) do
    ids = Enum.map(args, &String.to_integer/1)

    from(d in query,
      join: c in assoc(d, :categories),
      where: c.id in ^ids
    )
  end

  defp filter_active(query, nil), do: query

  defp filter_active(query, %{args: args, field: _}) do
    case args do
      [] -> query
      ["true"] -> from(d in query, where: d.is_active == true)
      ["false"] -> from(d in query, where: d.is_active == false)
      _ -> query
    end
  end

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(queryset, _options) do
    queryset
    |> Repo.all()
  end

  defp insert(struct) do
    %Deal{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Deal
    |> Repo.get(struct.id)
    |> Repo.preload(:business)
    |> Repo.preload(:categories)
    |> Repo.preload(:location)
    |> changeset(struct)
    |> Repo.update()
  end
end
