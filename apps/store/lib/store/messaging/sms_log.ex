defmodule Store.Messaging.SMSLog do
  use Store.Model

  # @sms_types ~w(campaign referral)

  schema "sms_log" do
    field(:phone, :string)
    field(:uuid, :string)
    field(:entity_id, :integer)
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)
    field(:type, :string)
    field(:status, :string)
    field(:message, :string)
    field(:error_code, :integer)
    field(:error_message, :string)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def get(uuid) do
    from(r in SMSLog,
      where: r.uuid == ^uuid
    )
    |> Repo.one()
  end

  def get_campaign_report(business_id, campaign_id, options) do
    from(r in SMSLog,
      join: l in assoc(r, :location),
      join: c in assoc(r, :customer),
      join: m in assoc(c, :memberships),
      join: ml in assoc(m, :locations),
      where:
        l.business_id == ^business_id and r.entity_id == ^campaign_id and
          ml.location_id == r.location_id and ml.is_active,
      select: %{
        id: r.id,
        customer: %{
          id: c.id,
          first_name: c.first_name,
          last_name: c.last_name,
          phone: c.phone
        },
        location_sms_enabled: ml.notifications_enabled,
        location_id: r.location_id,
        error_message: r.error_message,
        error_code: r.error_code,
        status: r.status
      }
    )
    |> filter(options)
    |> paginate(options)
  end

  def get_logs_for_campaign_by_error_code(location_id, campaign_id, error_code) do
    from(r in SMSLog,
      where:
        r.location_id == ^location_id and r.entity_id == ^campaign_id and
          r.error_code == ^error_code,
      select: %{
        id: r.id,
        customer_id: r.customer_id
      }
    )
    |> Repo.all()
  end

  def get_by_entity(id) do
    from(r in SMSLog,
      where: r.entity_id == ^id
    )
    |> Repo.all()
  end

  defp base_query(location_ids, types, message_filter) do
    query =
      from(s in SMSLog,
        where: s.location_id in ^location_ids and s.type in ^types
      )

    case message_filter do
      nil -> query
      message_filter -> query |> filter_message(message_filter)
    end
  end

  defp paginate(query, %{page: %{offset: offset, limit: limit}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp filter(query, %{filters: filters}) do
    query
    |> filter_error_code(find_filter(filters, "error_code"))
    |> filter_status(find_filter(filters, "status"))
  end

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_error_code(query, nil), do: query

  defp filter_error_code(query, %{args: args}) do
    args = Enum.map(args, &Integer.parse/1)
    args = Enum.map(args, fn {v, _} -> v end)

    from(p in query,
      where: p.error_code in ^args
    )
  end

  defp filter_status(query, nil), do: query

  defp filter_status(query, %{args: args}) do
    from(p in query,
      where: p.status in ^args
    )
  end

  defp filter_message(query, message_filter) do
    query |> where([s], ilike(s.message, ^"%#{message_filter}%"))
  end

  def metrics_query(location_ids, period, types, msg_filter) do
    case period do
      :today ->
        from(s in base_query(location_ids, types, msg_filter),
          join: l in assoc(s, :location),
          where:
            fragment(
              "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
              s.inserted_at,
              l.timezone,
              l.timezone,
              l.timezone
            ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              s.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                s.inserted_at,
                l.timezone
              ),
            value: count(s.id)
          }
        )

      :this_week ->
        from(s in base_query(location_ids, types, msg_filter),
          join: l in assoc(s, :location),
          where:
            fragment(
              "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
              s.inserted_at,
              l.timezone,
              l.timezone,
              l.timezone
            ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              s.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                s.inserted_at,
                l.timezone
              ),
            value: count(s.id)
          }
        )

      :this_month ->
        from(s in base_query(location_ids, types, msg_filter),
          join: l in assoc(s, :location),
          where:
            fragment(
              "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
              s.inserted_at,
              l.timezone,
              l.timezone,
              l.timezone
            ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              s.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                s.inserted_at,
                l.timezone
              ),
            value: count(s.id)
          }
        )

      :this_year ->
        from(s in base_query(location_ids, types, msg_filter),
          join: l in assoc(s, :location),
          where:
            fragment(
              "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
              s.inserted_at,
              l.timezone,
              l.timezone,
              l.timezone
            ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              s.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                s.inserted_at,
                l.timezone
              ),
            value: count(s.id)
          }
        )

      :this_year_to_date ->
        from(s in base_query(location_ids, types, msg_filter),
          join: l in assoc(s, :location),
          where:
            fragment(
              "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
              s.inserted_at,
              l.timezone,
              l.timezone,
              l.timezone
            ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              s.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                s.inserted_at,
                l.timezone
              ),
            value: count(s.id)
          }
        )

      :last_30 ->
        last_num_days(location_ids, types, msg_filter, 30, :day)

      :last_60 ->
        last_num_days(location_ids, types, msg_filter, 60, :day)

      :last_90 ->
        last_num_days(location_ids, types, msg_filter, 90, :day)

      :last_180 ->
        last_num_days(location_ids, types, msg_filter, 180, :month)

      :last_365 ->
        last_num_days(location_ids, types, msg_filter, 365, :month)

      :total ->
        from(s in base_query(location_ids, types, msg_filter),
          join: l in assoc(s, :location),
          where:
            fragment(
              "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', to_date('1970-01-01', 'YYYY-MM-DD') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
              s.inserted_at,
              l.timezone,
              l.timezone,
              l.timezone
            ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              s.inserted_at,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                s.inserted_at,
                l.timezone
              ),
            value: count(s.id)
          }
        )
    end
  end

  defp last_num_days(location_ids, types, msg_filter, days, :day) do
    from(s in base_query(location_ids, types, msg_filter),
      join: l in assoc(s, :location),
      where: s.inserted_at > ago(^days, "day") and s.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          s.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            s.inserted_at,
            l.timezone
          ),
        value: count(s.id)
      }
    )
  end

  defp last_num_days(location_ids, types, msg_filter, days, :month) do
    from(s in base_query(location_ids, types, msg_filter),
      join: l in assoc(s, :location),
      where: s.inserted_at > ago(^days, "day") and s.inserted_at <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          s.inserted_at,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            s.inserted_at,
            l.timezone
          ),
        value: count(s.id)
      }
    )
  end

  def metrics(location_ids, period, types, msg_filter \\ nil) do
    query = metrics_query(location_ids, period, types, msg_filter)

    case Repo.all(query) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def metrics_count(location_ids, period, types, msg_filter \\ nil) do
    count =
      metrics_query(location_ids, period, types, msg_filter)
      |> Repo.all()
      |> Enum.reduce(0, fn r, acc -> r.value + acc end)

    {:ok, count}
  end

  defp insert(struct) do
    %SMSLog{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    get(struct.uuid)
    |> changeset(struct)
    |> Repo.update()
  end

  def update_status(uuid, status, %{code: code, message: message}) do
    get(uuid)
    |> change(%{status: status, error_code: code, error_message: message})
    |> Repo.update()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      ~w(phone uuid entity_id type customer_id location_id status message error_code error_message)a
    )
    |> validate_required(~w(phone uuid type status message)a)
  end
end
