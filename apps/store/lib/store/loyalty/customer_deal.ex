defmodule Store.Loyalty.CustomerDeal do
  use Store.Model

  schema "customer_deals" do
    field(:name, :string)
    field(:expires, ConvertUTCDateTime)
    field(:redeemed, ConvertUTCDateTime)
    belongs_to(:deal, Store.Loyalty.Deal)
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %CustomerDeal{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def get(customer_id, customer_deal_id) do
    from(d in CustomerDeal,
      where: d.id == ^customer_deal_id and d.customer_id == ^customer_id
    )
    |> Repo.one()
  end

  def get_claims(deal_ids) do
    query =
      from(d in CustomerDeal,
        where: d.deal_id in ^deal_ids and not is_nil(d.redeemed),
        group_by: d.deal_id,
        select: %{deal_id: d.deal_id, count: count(d.deal_id)}
      )

    case Repo.all(query) do
      deals -> {:ok, deals}
    end
  end

  def redeem(customer_id, id) do
    query =
      from(d in CustomerDeal,
        where: d.id == ^id and d.customer_id == ^customer_id and is_nil(d.redeemed)
      )

    case Repo.one(query) do
      nil ->
        {:error, "Customer deal not found or already redeemed"}

      customer_deal ->
        customer_deal
        |> change(%{redeemed: DateTime.utc_now()})
        |> Repo.update()
    end
  end

  def redemptions(customer_id, options) do
    from(d in CustomerDeal,
      where: d.customer_id == ^customer_id and not is_nil(d.redeemed),
      order_by: [desc: d.redeemed]
    )
    |> paginate(options)
  end

  # @Note queued_up is being treated as redeemed to exclude deals from the
  # memberships query - if this causes problems we'll need a specific function
  # to deal with that - be careful if you use this method as it doesn't actually
  # check the redeemed boolean!
  def redeemed_by_customer(customer_id) do
    query =
      from(d in CustomerDeal,
        join: dd in assoc(d, :deal),
        join: l in assoc(d, :location),
        where:
          d.customer_id == ^customer_id and
            ((d.inserted_at >=
                fragment("DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || ''))", l.timezone) and
                dd.frequency_type == "daily") or dd.frequency_type == "single-use"),
        select: d.deal_id
      )

    case Repo.all(query) do
      {:error, error} -> {:error, error}
      result -> {:ok, result}
    end
  end

  defp metrics_query(business_id, location_ids, period) do
    case period do
      :today ->
        from(d in CustomerDeal,
          join: l in assoc(d, :location),
          where:
            l.business_id == ^business_id and d.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                d.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              d.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                d.redeemed,
                l.timezone
              ),
            value: count(d.id)
          }
        )

      :this_week ->
        from(d in CustomerDeal,
          join: l in assoc(d, :location),
          where:
            l.business_id == ^business_id and d.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
                d.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              d.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                d.redeemed,
                l.timezone
              ),
            value: count(d.id)
          }
        )

      :this_month ->
        from(d in CustomerDeal,
          join: l in assoc(d, :location),
          where:
            l.business_id == ^business_id and d.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
                d.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              d.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                d.redeemed,
                l.timezone
              ),
            value: count(d.id)
          }
        )

      :this_year ->
        from(d in CustomerDeal,
          join: l in assoc(d, :location),
          where:
            l.business_id == ^business_id and d.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                d.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              d.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                d.redeemed,
                l.timezone
              ),
            value: count(d.id)
          }
        )

      :this_year_to_date ->
        from(d in CustomerDeal,
          join: l in assoc(d, :location),
          where:
            l.business_id == ^business_id and d.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                d.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              d.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                d.redeemed,
                l.timezone
              ),
            value: count(d.id)
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
        from(d in CustomerDeal,
          join: l in assoc(d, :location),
          where:
            l.business_id == ^business_id and d.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
                d.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              d.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                d.redeemed,
                l.timezone
              ),
            value: count(d.id)
          }
        )
    end
  end

  defp last_num_days(business_id, location_ids, days, :day) do
    from(d in CustomerDeal,
      join: l in assoc(d, :location),
      where:
        l.business_id == ^business_id and d.location_id in ^location_ids and
          d.redeemed > ago(^days, "day") and d.redeemed <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          d.redeemed,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            d.redeemed,
            l.timezone
          ),
        value: count(d.id)
      }
    )
  end

  defp last_num_days(business_id, location_ids, days, :month) do
    from(d in CustomerDeal,
      join: l in assoc(d, :location),
      where:
        l.business_id == ^business_id and d.location_id in ^location_ids and
          d.redeemed > ago(^days, "day") and d.redeemed <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          d.redeemed,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            d.redeemed,
            l.timezone
          ),
        value: count(d.id)
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

  # @Note queued_up is being treated as redeemed to exclude deals from the
  # memberships query - if this causes problems we'll need a specific function
  # to deal with that - be careful if you use this method as it doesn't actually
  # check the redeemed boolean!
  def redeemed_at_location(customer_id, location_id) do
    query =
      from(d in CustomerDeal,
        join: dd in assoc(d, :deal),
        join: l in assoc(d, :location),
        where:
          d.customer_id == ^customer_id and d.location_id == ^location_id and
            ((fragment(
                "? AT TIME ZONE (?->>'id' || '') >= DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || ''))",
                d.inserted_at,
                l.timezone,
                l.timezone
              ) and dd.frequency_type == "daily") or dd.frequency_type == "single-use"),
        select: d.deal_id
      )

    case Repo.all(query) do
      {:error, error} -> {:error, error}
      result -> {:ok, result}
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(deal_id customer_id location_id name expires redeemed)a)
    |> validate_required(~w(deal_id customer_id location_id name expires)a)
    |> foreign_key_constraint(:deal_id)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:location_id)
  end

  def get_deals(customer_id) do
    from(d in CustomerDeal,
      join: dd in assoc(d, :deal),
      preload: [deal: dd],
      where:
        d.customer_id == ^customer_id and (d.expires > ^DateTime.utc_now() or is_nil(d.expires)) and
          is_nil(d.redeemed)
    )
    |> Repo.all()
  end

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(queryset, _options) do
    queryset
    |> Repo.all()
  end

  def get_deals_by_location(customer_id, location_id) do
    from(d in CustomerDeal,
      where:
        d.customer_id == ^customer_id and d.location_id == ^location_id and
          (d.expires > ^DateTime.utc_now() or is_nil(d.expires)) and is_nil(d.redeemed)
    )
    |> Repo.all()
  end
end
