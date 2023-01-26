defmodule Store.Loyalty.Transaction do
  use Store.Model

  @transaction_types ~w(credit debit)

  schema "transactions" do
    belongs_to(:location, Store.Location)
    belongs_to(:customer, Store.Customer)
    belongs_to(:employee, Store.Employee)
    field(:type, :string)
    field(:units, :integer)
    field(:meta, :map)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %Transaction{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def credit(transaction) do
    transaction
    |> Map.put(:type, "credit")
    |> create()
  end

  def debit(transaction) do
    transaction
    |> Map.put(:type, "debit")
    |> create()
  end

  def get_balance(customer_id, location_id) do
    {:ok, get_sum(customer_id, location_id)}
  end

  def get_for_customer_after_time(epoch_time, customer_id) do
    time = DateTime.from_unix!(epoch_time, :millisecond)

    from(t in Transaction,
      join: l in assoc(t, :location),
      where:
        t.customer_id == ^customer_id and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') > ? AT TIME ZONE (?->>'id' || '')",
            t.inserted_at,
            l.timezone,
            ^time,
            l.timezone
          ),
      limit: 1,
      select: %{
        id: t.id,
        location_id: t.location_id,
        units: t.units
      }
    )
    |> Repo.one()
  end

  def customer_has_earned_stamp(customer_id, location_id) do
    from(t in Transaction,
      where: t.customer_id == ^customer_id and t.location_id == ^location_id
    )
    |> Repo.exists?()
  end

  def has_not_earned_stamp_today(customer_id, location_id) do
    query =
      from(t in Transaction,
        join: l in assoc(t, :location),
        where:
          t.customer_id == ^customer_id and t.location_id == ^location_id and t.type == "credit" and
            fragment(
              "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
              t.inserted_at,
              l.timezone,
              l.timezone,
              l.timezone
            )
      )

    case Repo.aggregate(query, :count, :id) do
      0 -> {:ok, true}
      _ -> {:error, "already_earned_stamp_today:#{customer_id}"}
    end
  end

  defp get_sum(customer_id, location_id) do
    from(t in Transaction,
      select:
        fragment("SUM(CASE WHEN ? = 'credit' THEN (?) ELSE - (?) END)", t.type, t.units, t.units),
      where: t.customer_id == ^customer_id and t.location_id == ^location_id
    )
    |> Repo.one() || 0
  end

  def count_total_transactions_by_customer_and_location(customer_id, location_id) do
    from(t in Transaction,
      where: t.location_id == ^location_id and t.customer_id == ^customer_id
    )
    |> Repo.aggregate(:count, :id)
  end

  def metrics_query(type, business_id, location_ids, period) do
    case period do
      :today ->
        from(t in Transaction,
          join: l in assoc(t, :location),
          where:
            l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                t.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              t.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                t.inserted_at,
                l.timezone
              ),
            value: count(t.units)
          }
        )

      :this_week ->
        from(t in Transaction,
          join: l in assoc(t, :location),
          where:
            l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
                t.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              t.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                t.inserted_at,
                l.timezone
              ),
            value: count(t.units)
          }
        )

      :this_month ->
        from(t in Transaction,
          join: l in assoc(t, :location),
          where:
            l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
                t.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              t.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                t.inserted_at,
                l.timezone
              ),
            value: count(t.units)
          }
        )

      :this_year ->
        from(t in Transaction,
          join: l in assoc(t, :location),
          where:
            l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                t.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              t.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                t.inserted_at,
                l.timezone
              ),
            value: count(t.units)
          }
        )

      :this_year_to_date ->
        from(t in Transaction,
          join: l in assoc(t, :location),
          where:
            l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                t.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              t.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                t.inserted_at,
                l.timezone
              ),
            value: count(t.units)
          }
        )

      :last_30 ->
        last_num_days(business_id, location_ids, type, 30, :day)

      :last_60 ->
        last_num_days(business_id, location_ids, type, 60, :day)

      :last_90 ->
        last_num_days(business_id, location_ids, type, 90, :day)

      :last_180 ->
        last_num_days(business_id, location_ids, type, 180, :month)

      :last_365 ->
        last_num_days(business_id, location_ids, type, 365, :month)

      :total ->
        from(t in Transaction,
          join: l in assoc(t, :location),
          where:
            l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
                t.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              t.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                t.inserted_at,
                l.timezone
              ),
            value: count(t.units)
          }
        )
    end
  end

  defp last_num_days(business_id, location_ids, type, days, :day) do
    from(t in Transaction,
      join: l in assoc(t, :location),
      where:
        l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
          t.inserted_at > ago(^days, "day") and t.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          t.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            t.inserted_at,
            l.timezone
          ),
        value: count(t.units)
      }
    )
  end

  defp last_num_days(business_id, location_ids, type, days, :month) do
    from(t in Transaction,
      join: l in assoc(t, :location),
      where:
        l.business_id == ^business_id and t.location_id in ^location_ids and t.type == ^type and
          t.inserted_at > ago(^days, "day") and t.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          t.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            t.inserted_at,
            l.timezone
          ),
        value: count(t.units)
      }
    )
  end

  def metrics(type, business_id, location_ids, period) do
    query = metrics_query(type, business_id, location_ids, period)

    case Repo.all(query) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def metrics_count(type, business_id, location_ids, period) do
    count =
      metrics_query(type, business_id, location_ids, period)
      |> Repo.all()
      |> Enum.reduce(0, fn r, acc -> r.value + acc end)

    {:ok, count}
  end

  def customers_last_mile_query(active_customer_ids, location_id) do
    from(t in Transaction,
      join: c in assoc(t, :customer),
      join: l in assoc(t, :location),
      inner_lateral_join:
        reward in fragment(
          "SELECT (points-1) as last_mile FROM rewards WHERE location_id = ? and type = ?",
          l.id,
          "loyalty"
        ),
      where: c.id in ^active_customer_ids and l.id == ^location_id,
      group_by: [c.id, l.id, reward.last_mile],
      having:
        fragment("SUM(CASE WHEN ? = 'credit' THEN (?) ELSE - (?) END)", t.type, t.units, t.units) ==
          reward.last_mile,
      select: c
    )
  end

  def customers_last_mile_count(active_customer_ids, location_id) do
    inner_query = customers_last_mile_query(active_customer_ids, location_id)

    query =
      from(c in subquery(inner_query),
        select: count("*")
      )

    case Repo.aggregate(query, :count, :id) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(location_id customer_id employee_id type units meta)a)
    |> validate_required(~w(location_id customer_id type units meta)a)
    |> validate_inclusion(:type, @transaction_types)
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:customer_id)
  end
end
