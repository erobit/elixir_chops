defmodule Store.Review do
  use Store.Model

  schema "reviews" do
    field(:content, :string)
    field(:rating, :integer)
    field(:completed, :boolean, default: false)
    belongs_to(:location, Location)
    belongs_to(:customer, Customer)
    timestamps(type: :utc_datetime)
  end

  ####################
  # Public Functions
  ####################

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def is_complete?(review) do
    case Map.get(review, :id) do
      nil ->
        false

      id ->
        from(r in Review,
          where: r.id == ^id,
          select: [:completed]
        )
        |> Repo.one()
        |> Map.get(:completed)
    end
  end

  def get_all(business_id, location_ids, options) do
    from(lr in Review,
      join: l in assoc(lr, :location),
      where:
        l.business_id == ^business_id and lr.completed and l.is_active and l.id in ^location_ids,
      select: lr
    )
    |> preload(:customer)
    |> preload(:location)
    |> filter(options)
    |> sort(options)
    |> Repo.paginate(page: options.options.page.offset, page_size: options.options.page.limit)
  end

  def get_all(location_id, customer_id) do
    from(r in Review,
      where: r.location_id == ^location_id and r.completed,
      order_by: [{:desc, r.inserted_at}],
      select: %{
        id: r.id,
        rating: r.rating,
        content: r.content,
        inserted_at: r.inserted_at,
        is_yours: r.customer_id == ^customer_id
      }
    )
    |> Repo.all()
  end

  def get_review_by_customer_and_location(customer_id, location_id) do
    from(lr in Review,
      where: lr.customer_id == ^customer_id and lr.location_id == ^location_id
    )
    |> Repo.one()
  end

  def metrics_query(business_id, location_ids, period) do
    case period do
      :today ->
        from(r in Review,
          join: l in assoc(r, :location),
          where:
            r.completed == true and l.business_id == ^business_id and
              r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                r.updated_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              r.updated_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                r.updated_at,
                l.timezone
              ),
            value: count(r.id),
            average: avg(r.rating)
          }
        )

      :this_week ->
        from(r in Review,
          join: l in assoc(r, :location),
          where:
            r.completed == true and l.business_id == ^business_id and
              r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
                r.updated_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              r.updated_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                r.updated_at,
                l.timezone
              ),
            value: count(r.id),
            average: avg(r.rating)
          }
        )

      :this_month ->
        from(r in Review,
          join: l in assoc(r, :location),
          where:
            r.completed == true and l.business_id == ^business_id and
              r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
                r.updated_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              r.updated_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                r.updated_at,
                l.timezone
              ),
            value: count(r.id),
            average: avg(r.rating)
          }
        )

      :this_year ->
        from(r in Review,
          join: l in assoc(r, :location),
          where:
            r.completed == true and l.business_id == ^business_id and
              r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                r.updated_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              r.updated_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                r.updated_at,
                l.timezone
              ),
            value: count(r.id),
            average: avg(r.rating)
          }
        )

      :this_year_to_date ->
        from(r in Review,
          join: l in assoc(r, :location),
          where:
            r.completed == true and l.business_id == ^business_id and
              r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                r.updated_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              r.updated_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                r.updated_at,
                l.timezone
              ),
            value: count(r.id),
            average: avg(r.rating)
          }
        )

      :last_30 ->
        last_num_days(business_id, location_ids, 30, :day)

      :last_60 ->
        last_num_days(business_id, location_ids, 60, :day)

      :last_90 ->
        last_num_days(business_id, location_ids, 90, :day)

      :last_180 ->
        last_num_days(business_id, location_ids, 180, :month)

      :last_365 ->
        last_num_days(business_id, location_ids, 365, :month)

      :total ->
        from(r in Review,
          join: l in assoc(r, :location),
          where:
            r.completed == true and l.business_id == ^business_id and
              r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
                r.updated_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              r.updated_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                r.updated_at,
                l.timezone
              ),
            value: count(r.id),
            average: avg(r.rating)
          }
        )
    end
  end

  defp last_num_days(business_id, location_ids, days, :day) do
    from(r in Review,
      join: l in assoc(r, :location),
      where:
        r.completed == true and l.business_id == ^business_id and r.location_id in ^location_ids and
          r.updated_at > ago(^days, "day") and r.updated_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          r.updated_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            r.updated_at,
            l.timezone
          ),
        value: count(r.id),
        average: avg(r.rating)
      }
    )
  end

  defp last_num_days(business_id, location_ids, days, :month) do
    from(r in Review,
      join: l in assoc(r, :location),
      where:
        r.completed == true and l.business_id == ^business_id and r.location_id in ^location_ids and
          r.updated_at > ago(^days, "day") and r.updated_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          r.updated_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            r.updated_at,
            l.timezone
          ),
        value: count(r.id),
        average: avg(r.rating)
      }
    )
  end

  def metrics(business_id, location_ids, period, aggregate) do
    metrics =
      metrics_query(business_id, location_ids, period)
      |> Repo.all()

    case aggregate do
      :avg ->
        result =
          metrics
          |> Enum.map(fn v ->
            %{
              id: v.id,
              created: v.created,
              value: Decimal.to_float(v.average)
            }
          end)

        {:ok, result}

      :count ->
        {:ok, metrics}
    end
  end

  def metrics_count(business_id, location_ids, period, aggregate) do
    results =
      metrics_query(business_id, location_ids, period)
      |> Repo.all()

    case aggregate do
      :avg ->
        result =
          results
          |> Enum.map(fn r -> Decimal.to_float(r.average) end)
          |> Enum.sum()

        case length(results) do
          0 ->
            {:ok, 0}

          _ ->
            result = Decimal.from_float(result / length(results))
            {:ok, Decimal.round(result, 1) |> Decimal.to_float()}
        end

      :count ->
        result =
          results
          |> Enum.map(fn r -> r.value end)
          |> Enum.sum()

        {:ok, result}
    end
  end

  ####################
  # Private Functions
  ####################

  defp filter(query, %{options: %{filters: filters}}) do
    location_filter = find_filter(filters, "location_id")

    query
    |> filter_locations(location_filter)
  end

  defp filter(query, _options), do: query

  defp filter_locations(query, nil), do: query

  defp filter_locations(query, %{args: args, field: _}) do
    from(l in query,
      where: l.location_id in ^args
    )
  end

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp sort(query, %{options: %{sort: %{field: fieldname, order: order}}}) do
    direction = if order == 1, do: :asc, else: :desc
    query |> order_by([d], [{^direction, field(d, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _) do
    query
    |> order_by([r], [{:desc, r.updated_at}])
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, ~w(content completed rating customer_id location_id)a)
    |> validate_required(~w(customer_id location_id)a)
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:customer_id)
    |> unique_constraint(:customer_id, name: "location_review_customer_location_index")
  end

  defp insert(struct) do
    %Review{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Review
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end
end
