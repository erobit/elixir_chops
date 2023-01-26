defmodule Store.Loyalty.MembershipLocation do
  use Store.Model

  schema "membership_locations" do
    belongs_to(:membership, Store.Loyalty.Membership)
    belongs_to(:location, Store.Location)
    field(:is_active, :boolean, null: false, default: true)
    field(:notifications_enabled, :boolean, default: true)
    field(:opted_out, :boolean, default: false)
    timestamps(type: :utc_datetime)
  end

  def get(membership_id, location_id) do
    from(m in MembershipLocation,
      where: m.membership_id == ^membership_id and m.location_id == ^location_id
    )
    |> Repo.one()
  end

  def get_by_customer_and_location(customer_id, location_id) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      where: m.customer_id == ^customer_id and ml.location_id == ^location_id,
      select: m
    )
    |> Repo.one()
  end

  def get_by_customer(business_id, customer_id) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      join: l in assoc(ml, :location),
      where:
        m.customer_id == ^customer_id and m.business_id == ^business_id and ml.is_active == true,
      select: l
    )
    |> Repo.all()
  end

  def get_by_customer(customer_id) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      where: m.customer_id == ^customer_id,
      select: ml
    )
    |> Repo.all()
  end

  def get_by_membership(membership_id) do
    from(ml in MembershipLocation,
      where: ml.membership_id == ^membership_id,
      select: ml
    )
    |> Repo.all()
  end

  def active_membership_locations_by_business(business_id) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      join: loc in assoc(ml, :location),
      where: m.business_id == ^business_id and ml.is_active == true and loc.is_active == true
    )
    |> Repo.all()
  end

  def active_membership_locations_by_customers_query(customer_ids) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      join: c in assoc(m, :customer),
      join: loc in assoc(ml, :location),
      where: m.customer_id in ^customer_ids and ml.is_active == true and loc.is_active == true,
      group_by: [c.id],
      having: count(c.id) > 0,
      select: c
    )
  end

  def active_customers_query(location_ids) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      join: c in assoc(m, :customer),
      join: loc in assoc(ml, :location),
      where: loc.id in ^location_ids and ml.is_active == true and loc.is_active == true,
      group_by: [c.id],
      having: count(c.id) > 0,
      distinct: c.id,
      select: c
    )
  end

  def active_customer_ids(location_ids) do
    active_customers_query(location_ids)
    |> Repo.all()
    |> Enum.map(fn c -> c.id end)
  end

  def active_membership_locations_by_customers(customer_ids) do
    active_membership_locations_by_customers_query(customer_ids)
    |> Repo.all()
  end

  def notifications_enabled(customer_ids, location_ids) do
    enabled =
      from(ml in MembershipLocation,
        join: m in assoc(ml, :membership),
        join: l in assoc(ml, :location),
        where:
          m.customer_id in ^customer_ids and l.id in ^location_ids and l.is_active == true and
            ml.is_active == true and ml.notifications_enabled == true,
        select: %{customer_id: m.customer_id, location_id: l.id}
      )
      |> Repo.all()

    {:ok, enabled}
  end

  def set_location_notifications(membership_id, location_id, is_enabled) do
    MembershipLocation
    |> Repo.get_by(membership_id: membership_id, location_id: location_id)
    |> change(%{notifications_enabled: is_enabled})
    |> Repo.update()
  end

  def metrics_query(business_id, location_ids, period) do
    case period do
      :today ->
        from(ml in MembershipLocation,
          join: m in assoc(ml, :membership),
          join: l in assoc(ml, :location),
          where:
            m.business_id == ^business_id and ml.location_id in ^location_ids and
              ml.is_active == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                ml.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              ml.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                ml.inserted_at,
                l.timezone
              ),
            value: count(ml.id)
          }
        )

      :this_week ->
        from(ml in MembershipLocation,
          join: m in assoc(ml, :membership),
          join: l in assoc(ml, :location),
          where:
            m.business_id == ^business_id and ml.location_id in ^location_ids and
              ml.is_active == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
                ml.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              ml.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                ml.inserted_at,
                l.timezone
              ),
            value: count(ml.id)
          }
        )

      :this_month ->
        from(ml in MembershipLocation,
          join: m in assoc(ml, :membership),
          join: l in assoc(ml, :location),
          where:
            m.business_id == ^business_id and ml.location_id in ^location_ids and
              ml.is_active == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
                ml.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              ml.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                ml.inserted_at,
                l.timezone
              ),
            value: count(ml.id)
          }
        )

      :this_year ->
        from(ml in MembershipLocation,
          join: m in assoc(ml, :membership),
          join: l in assoc(ml, :location),
          where:
            m.business_id == ^business_id and ml.location_id in ^location_ids and
              ml.is_active == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                ml.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              ml.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                ml.inserted_at,
                l.timezone
              ),
            value: count(ml.id)
          }
        )

      :this_year_to_date ->
        from(ml in MembershipLocation,
          join: m in assoc(ml, :membership),
          join: l in assoc(ml, :location),
          where:
            m.business_id == ^business_id and ml.location_id in ^location_ids and
              ml.is_active == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                ml.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              ml.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                ml.inserted_at,
                l.timezone
              ),
            value: count(ml.id)
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
        from(ml in MembershipLocation,
          join: m in assoc(ml, :membership),
          join: l in assoc(ml, :location),
          where:
            m.business_id == ^business_id and ml.location_id in ^location_ids and
              ml.is_active == true and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
                ml.inserted_at,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              ml.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                ml.inserted_at,
                l.timezone
              ),
            value: count(ml.id)
          }
        )
    end
  end

  defp last_num_days(business_id, location_ids, days, :day) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      join: l in assoc(ml, :location),
      where:
        m.business_id == ^business_id and ml.location_id in ^location_ids and ml.is_active == true and
          ml.inserted_at > ago(^days, "day") and ml.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          ml.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            ml.inserted_at,
            l.timezone
          ),
        value: count(ml.id)
      }
    )
  end

  defp last_num_days(business_id, location_ids, days, :month) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      join: l in assoc(ml, :location),
      where:
        m.business_id == ^business_id and ml.location_id in ^location_ids and ml.is_active == true and
          ml.inserted_at > ago(^days, "day") and ml.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          ml.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            ml.inserted_at,
            l.timezone
          ),
        value: count(ml.id)
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

  def create(struct) do
    %MembershipLocation{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def set_active(membership_id, location_id) do
    set_active_status(membership_id, location_id, true)
  end

  def set_inactive(membership_id, location_id) do
    set_active_status(membership_id, location_id, false)
  end

  def is_active?(membership_id, location_id) do
    case Repo.get_by(MembershipLocation, membership_id: membership_id, location_id: location_id) do
      nil -> false
      record -> record.is_active
    end
  end

  defp set_active_status(membership_id, location_id, is_active) do
    MembershipLocation
    |> Repo.get_by(membership_id: membership_id, location_id: location_id)
    |> change(%{is_active: is_active})
    |> Repo.update()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(membership_id location_id is_active notifications_enabled)a)
    |> validate_required(~w(membership_id location_id)a)
    |> unique_constraint(:membership_and_location_id, name: :membership_locations_index)
    |> foreign_key_constraint(:membership_id)
    |> foreign_key_constraint(:location_id)
  end

  def toggle_notifications(membership_id, is_enabled) do
    from(ml in MembershipLocation,
      where: ml.membership_id == ^membership_id
    )
    |> Repo.update_all(set: [notifications_enabled: is_enabled])
  end

  def toggle_notifications(membership_id, location_id, is_enabled) do
    from(ml in MembershipLocation,
      where: ml.membership_id == ^membership_id and ml.location_id == ^location_id
    )
    |> Repo.update_all(set: [notifications_enabled: is_enabled])
  end

  def toggle_notifications_by_location_ids(customer_id, location_ids, is_enabled) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      where: m.customer_id == ^customer_id and ml.location_id in ^location_ids
    )
    |> Repo.update_all(set: [notifications_enabled: is_enabled])
  end

  def opted_in_or_out(customer_id, location_ids, is_enabled) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      where: m.customer_id == ^customer_id and ml.location_id in ^location_ids
    )
    |> Repo.update_all(set: [notifications_enabled: is_enabled, opted_out: !is_enabled])
  end

  def toggle_notifications_by_id(id, is_enabled) do
    from(ml in MembershipLocation,
      join: m in assoc(ml, :membership),
      where: ml.id == ^id
    )
    |> Repo.update_all(set: [notifications_enabled: is_enabled])
  end

  def delete(customer_id) do
    statement =
      from(ml in MembershipLocation,
        join: m in assoc(ml, :membership),
        where: m.customer_id == ^customer_id
      )

    case Repo.delete_all(statement) do
      {num_results, nil} -> {:ok, num_results}
      _ -> {:error, "could_not_delete_membership_locations"}
    end
  end
end
