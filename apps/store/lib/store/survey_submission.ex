defmodule Store.SurveySubmission do
  use Store.Model

  schema "survey_submissions" do
    field(:answers, :string, null: false)
    belongs_to(:survey, Survey)
    belongs_to(:customer, Customer)
    belongs_to(:location, Location)
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

  def get(id, business_id) do
    from(ss in SurveySubmission,
      join: s in assoc(ss, :survey),
      where: s.business_id == ^business_id and ss.id == ^id
    )
    |> preload(:customer)
    |> preload(:survey)
    |> preload(:location)
    |> Repo.one()
  end

  def get_submission_counts(survey_ids) do
    query =
      from(s in SurveySubmission,
        where: s.survey_id in ^survey_ids,
        group_by: s.survey_id,
        select: %{survey_id: s.survey_id, count: count(s.survey_id)}
      )

    case Repo.all(query) do
      deals -> {:ok, deals}
    end
  end

  def paginate(business_id, options) do
    from(ss in SurveySubmission,
      join: s in assoc(ss, :survey),
      join: c in assoc(ss, :customer),
      where: s.business_id == ^business_id
    )
    |> filter(options)
    |> preload(:customer)
    |> Repo.paginate(page: options.options.page.offset, page_size: options.options.page.limit)
  end

  def metrics_query(business_id, location_ids, period) do
    case period do
      :today ->
        from(s in SurveySubmission,
          join: l in assoc(s, :location),
          where:
            l.business_id == ^business_id and s.location_id in ^location_ids and
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
        from(s in SurveySubmission,
          join: l in assoc(s, :location),
          where:
            l.business_id == ^business_id and s.location_id in ^location_ids and
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
        from(s in SurveySubmission,
          join: l in assoc(s, :location),
          where:
            l.business_id == ^business_id and s.location_id in ^location_ids and
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
        from(s in SurveySubmission,
          join: l in assoc(s, :location),
          where:
            l.business_id == ^business_id and s.location_id in ^location_ids and
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
        from(s in SurveySubmission,
          join: l in assoc(s, :location),
          where:
            l.business_id == ^business_id and s.location_id in ^location_ids and
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
        from(s in SurveySubmission,
          join: l in assoc(s, :location),
          where:
            l.business_id == ^business_id and s.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
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

  defp last_num_days(business_id, location_ids, days, :day) do
    from(s in SurveySubmission,
      join: l in assoc(s, :location),
      where:
        l.business_id == ^business_id and s.location_id in ^location_ids and
          s.inserted_at > ago(^days, "day") and s.inserted_at <= ^DateTime.utc_now(),
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

  defp last_num_days(business_id, location_ids, days, :month) do
    from(s in SurveySubmission,
      join: l in assoc(s, :location),
      where:
        l.business_id == ^business_id and s.location_id in ^location_ids and
          s.inserted_at > ago(^days, "day") and s.inserted_at <= ^DateTime.utc_now(),
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
      |> Enum.reduce(0, fn v, acc -> v.value + acc end)

    {:ok, count}
  end

  ####################
  # Private Functions
  ####################

  defp insert(struct) do
    %SurveySubmission{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    SurveySubmission
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, ~w(answers survey_id location_id customer_id)a)
    |> validate_required(~w(answers survey_id location_id customer_id)a)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:survey_id)
    |> foreign_key_constraint(:location_id)
  end

  defp filter(query, %{options: %{filters: filters}}) do
    survey_filter = find_filter(filters, "survey_id")

    case survey_filter do
      nil ->
        query

      %{args: args, field: _} ->
        ids = Enum.map(args, &String.to_integer/1)

        from(ss in query,
          join: s in assoc(ss, :survey),
          where: s.id in ^ids
        )
    end
  end

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end
end
