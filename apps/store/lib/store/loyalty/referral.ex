defmodule Store.Loyalty.Referral do
  use Store.Model

  # referral record is created once web form is filled out

  # mark referral as complete during QR code scan for matching phone number
  # and insert the referral reward to the from_customer
  schema "referrals" do
    field(:recipient_phone, :string)
    field(:is_completed, :boolean)
    belongs_to(:business, Store.Business)
    belongs_to(:location, Store.Location)
    belongs_to(:from_customer, Store.Customer)
    belongs_to(:to_customer, Store.Customer)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %Referral{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def has_completed?(phone) do
    query =
      from(r in Referral,
        where: r.recipient_phone == ^phone and r.is_completed == true,
        limit: 1,
        select: r
      )

    case Repo.one(query) do
      nil -> false
      _ -> true
    end
  end

  def has_completed?(phone, location_id) do
    query =
      from(r in Referral,
        where:
          r.recipient_phone == ^phone and r.location_id == ^location_id and r.is_completed == true,
        limit: 1,
        select: r
      )

    case Repo.one(query) do
      nil -> false
      _ -> true
    end
  end

  def get_by_phone(phone) do
    case has_completed?(phone) do
      true ->
        nil

      false ->
        from(r in Referral,
          preload: [:location],
          where: r.recipient_phone == ^phone and r.is_completed == false,
          order_by: [desc: r.inserted_at],
          limit: 1,
          select: r
        )
        |> Repo.one()
    end
  end

  def get_not_completed_by_phone(phone) do
    from(r in Referral,
      preload: [:location],
      where: r.recipient_phone == ^phone and r.is_completed == false,
      order_by: [desc: r.inserted_at],
      limit: 1,
      select: r
    )
    |> Repo.one()
  end

  def get(phone, location_id) do
    case has_completed?(phone, location_id) do
      true ->
        nil

      false ->
        from(r in Referral,
          where:
            r.recipient_phone == ^phone and r.location_id == ^location_id and
              r.is_completed == false,
          order_by: [desc: r.inserted_at],
          limit: 1,
          select: r
        )
        |> Repo.one()
    end
  end

  def mark_as_completed(id, customer_id) do
    Referral
    |> Repo.get(id)
    |> change(%{is_completed: true, to_customer_id: customer_id})
    |> Repo.update()
  end

  def metrics_query(business_id, location_ids, period) do
    case period do
      :today ->
        from(r in Referral,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              r.is_completed == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                r.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              r.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                r.inserted_at,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_week ->
        from(r in Referral,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              r.is_completed == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
                r.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              r.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                r.inserted_at,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_month ->
        from(r in Referral,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              r.is_completed == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
                r.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              r.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                r.inserted_at,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_year ->
        from(r in Referral,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              r.is_completed == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                r.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              r.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                r.inserted_at,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_year_to_date ->
        from(r in Referral,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              r.is_completed == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                r.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              r.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                r.inserted_at,
                l.timezone
              ),
            value: count(r.id)
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
        from(r in Referral,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              r.is_completed == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
                r.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              r.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                r.inserted_at,
                l.timezone
              ),
            value: count(r.id)
          }
        )
    end
  end

  defp last_num_days(business_id, location_ids, days, :day) do
    from(r in Referral,
      join: l in assoc(r, :location),
      where:
        l.business_id == ^business_id and r.location_id in ^location_ids and
          r.is_completed == true and r.inserted_at > ago(^days, "day") and
          r.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          r.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            r.inserted_at,
            l.timezone
          ),
        value: count(r.id)
      }
    )
  end

  defp last_num_days(business_id, location_ids, days, :month) do
    from(r in Referral,
      join: l in assoc(r, :location),
      where:
        l.business_id == ^business_id and r.location_id in ^location_ids and
          r.is_completed == true and r.inserted_at > ago(^days, "day") and
          r.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          r.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            r.inserted_at,
            l.timezone
          ),
        value: count(r.id)
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

  def customers_referral_query(active_customer_ids, location_id) do
    from(r in Referral,
      join: c in assoc(r, :from_customer),
      where:
        c.id in ^active_customer_ids and r.location_id == ^location_id and r.is_completed == true,
      group_by: [c.id],
      order_by: [desc: count("*")],
      select: c
    )
  end

  def customers_referral_count(active_customer_ids, location_id) do
    inner_query = customers_referral_query(active_customer_ids, location_id)

    query =
      from(c in subquery(inner_query),
        select: count("*")
      )

    case Repo.one(query) do
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

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(recipient_phone is_completed
      business_id location_id from_customer_id)a)
    |> validate_required(~w(recipient_phone is_completed
      business_id location_id from_customer_id)a)
    |> foreign_key_constraint(:business_id)
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:from_customer_id)
    |> unique_constraint(:customer_location_and_phone,
      name: :referrals_from_customer_id_location_id_recipient_phone_index
    )
  end
end
