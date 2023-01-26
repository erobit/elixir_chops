defmodule Store.Visit do
  use Store.Model

  schema "visits" do
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)
    field(:point, Geo.PostGIS.Geometry)
    timestamps(type: :utc_datetime)
  end

  def count_by_customer(customer_id, location_id) do
    from(v in Visit,
      where: v.customer_id == ^customer_id and v.location_id == ^location_id
    )
    |> Repo.aggregate(:count, :id)
  end

  def count_by_location(location_id) do
    from(v in Visit,
      where: v.location_id == ^location_id
    )
    |> Repo.aggregate(:count, :id)
  end

  def last_hour_count(customer_id, location_id) do
    from(v in Visit,
      join: l in assoc(v, :location),
      where:
        v.customer_id == ^customer_id and v.location_id == ^location_id and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') BETWEEN (now() AT TIME ZONE (?->>'id' || '') - interval '1 hour') AND (now() AT TIME ZONE (?->>'id' || ''))",
            v.inserted_at,
            l.timezone,
            l.timezone,
            l.timezone
          )
    )
    |> Repo.aggregate(:count, :id)
  end

  def today_count(customer_id, location_id) do
    from(v in Visit,
      join: l in assoc(v, :location),
      where:
        v.customer_id == ^customer_id and v.location_id == ^location_id and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
            v.inserted_at,
            l.timezone,
            l.timezone,
            l.timezone
          )
    )
    |> Repo.aggregate(:count, :id)
  end

  def count_by_business(business_id) do
    from(v in Visit,
      join: l in assoc(v, :location),
      where: l.business_id == ^business_id
    )
    |> Repo.aggregate(:count, :id)
  end

  def count_by_campaign(campaign) do
    customer_ids = Enum.map(campaign.customers, fn c -> c.id end)
    iso_date = Date.to_iso8601(campaign.send_date)

    send_date_time =
      case campaign.send_time do
        nil -> iso_date <> "T00:00:00.000000Z"
        _ -> iso_date <> "T" <> Time.to_iso8601(campaign.send_time) <> "Z"
      end

    {:ok, send_date_time, _} = DateTime.from_iso8601(send_date_time)

    from(v in Visit,
      join: l in assoc(v, :location),
      where:
        l.business_id == ^campaign.business_id and v.location_id == ^campaign.location_id and
          v.customer_id in ^customer_ids and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') BETWEEN ? AND (?::timestamp + interval '47 hours 59 minutes 59 seconds')",
            v.inserted_at,
            l.timezone,
            ^send_date_time,
            ^send_date_time
          ),
      select: %{id: v.id, created: v.inserted_at, value: 1}
    )
    |> Repo.aggregate(:count, :id)
  end

  def metrics_query(business_id, location_ids, period) do
    case period do
      :today ->
        from(v in Visit,
          join: l in assoc(v, :location),
          where:
            l.business_id == ^business_id and v.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                v.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              v.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                v.inserted_at,
                l.timezone
              ),
            value: count(v.id)
          }
        )

      :this_week ->
        from(v in Visit,
          join: l in assoc(v, :location),
          where:
            l.business_id == ^business_id and v.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
                v.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              v.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                v.inserted_at,
                l.timezone
              ),
            value: count(v.id)
          }
        )

      :this_month ->
        from(v in Visit,
          join: l in assoc(v, :location),
          where:
            l.business_id == ^business_id and v.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
                v.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              v.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                v.inserted_at,
                l.timezone
              ),
            value: count(v.id)
          }
        )

      :this_year ->
        from(v in Visit,
          join: l in assoc(v, :location),
          where:
            l.business_id == ^business_id and v.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                v.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              v.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                v.inserted_at,
                l.timezone
              ),
            value: count(v.id)
          }
        )

      :this_year_to_date ->
        from(v in Visit,
          join: l in assoc(v, :location),
          where:
            l.business_id == ^business_id and v.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                v.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              v.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                v.inserted_at,
                l.timezone
              ),
            value: count(v.id)
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
        from(v in Visit,
          join: l in assoc(v, :location),
          where:
            l.business_id == ^business_id and v.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
                v.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              v.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                v.inserted_at,
                l.timezone
              ),
            value: count(v.id)
          }
        )
    end
  end

  defp last_num_days(business_id, location_ids, days, :day) do
    from(v in Visit,
      join: l in assoc(v, :location),
      where:
        l.business_id == ^business_id and v.location_id in ^location_ids and
          v.inserted_at > ago(^days, "day") and v.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          v.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            v.inserted_at,
            l.timezone
          ),
        value: count(v.id)
      }
    )
  end

  defp last_num_days(business_id, location_ids, days, :month) do
    from(v in Visit,
      join: l in assoc(v, :location),
      where:
        l.business_id == ^business_id and v.location_id in ^location_ids and
          v.inserted_at > ago(^days, "day") and v.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          v.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            v.inserted_at,
            l.timezone
          ),
        value: count(v.id)
      }
    )
  end

  def metrics(business_id, location_ids, period) do
    query = metrics_query(business_id, location_ids, period)

    case Repo.all(query) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def metrics_count(business_id, location_ids, period) do
    count =
      metrics_query(business_id, location_ids, period)
      |> Repo.all()
      |> Enum.reduce(0, fn r, acc -> r.value + acc end)

    {:ok, count}
  end

  def customers_loyal_query(active_customer_ids, location_id) do
    # customer has visited 4+ times in the last 4 weeks
    from(v in Visit,
      join: c in assoc(v, :customer),
      join: l in assoc(v, :location),
      group_by: [c.id, l.id],
      having: count(c.id) >= 4,
      where:
        c.id in ^active_customer_ids and l.id == ^location_id and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '') - interval '4 weeks') AND now() AT TIME ZONE (?->>'id' || '')",
            v.inserted_at,
            l.timezone,
            l.timezone,
            l.timezone
          ),
      distinct: c.id,
      select: c
    )
  end

  def customers_loyal_count(active_customer_ids, location_id) do
    inner_query = customers_loyal_query(active_customer_ids, location_id)

    query =
      from(c in subquery(inner_query),
        select: count("*")
      )

    case Repo.one(query) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def customers_casual_query(active_customer_ids, location_id) do
    # customer has visited 1-3 times in the last 4 weeks
    from(v in Visit,
      join: c in assoc(v, :customer),
      join: l in assoc(v, :location),
      where:
        c.id in ^active_customer_ids and l.id == ^location_id and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '') - interval '4 weeks') AND now() AT TIME ZONE (?->>'id' || '')",
            v.inserted_at,
            l.timezone,
            l.timezone,
            l.timezone
          ),
      group_by: [c.id, l.id],
      having: count(c.id) >= 1 and count(c.id) <= 3,
      distinct: c.id,
      select: c
    )
  end

  def customers_casual_count(active_customer_ids, location_id) do
    inner_query = customers_casual_query(active_customer_ids, location_id)

    query =
      from(c in subquery(inner_query),
        select: count("*")
      )

    case Repo.one(query) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def create(struct) do
    %Visit{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(customer_id location_id point)a)
    |> validate_required(~w(customer_id location_id)a)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:location_id)
  end
end
