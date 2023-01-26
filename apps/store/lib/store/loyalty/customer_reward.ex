defmodule Store.Loyalty.CustomerReward do
  use Store.Model

  @reward_types ~w(loyalty first_time birthday referral facebook)
  def reward_types, do: @reward_types

  schema "customer_rewards" do
    field(:name, :string)
    field(:type, :string)
    field(:points, :integer)
    field(:expires, ConvertUTCDateTime)
    field(:redeemed, ConvertUTCDateTime)
    belongs_to(:reward, Store.Loyalty.Reward)
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %CustomerReward{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def get(id) do
    CustomerReward |> Repo.get(id)
  end

  def set_expiry(customer_id, customer_reward_id, expiry_date) do
    from(r in CustomerReward,
      where: r.id == ^customer_reward_id and r.customer_id == ^customer_id
    )
    |> Repo.one()
    |> change(%{expires: expiry_date})
    |> Repo.update()
  end

  def get(customer_id, customer_reward_id) do
    from(r in CustomerReward,
      where: r.id == ^customer_reward_id and r.customer_id == ^customer_id
    )
    |> Repo.one()
  end

  # if the reward is already queue up and hasn't expired, then return an error
  # as we don't want to create a new customer reward if one already exists
  def can_queue(customer_id, reward_id) do
    query =
      from(r in CustomerReward,
        where:
          r.id == ^reward_id and r.customer_id == ^customer_id and
            r.expires >= ^DateTime.utc_now()
      )

    case Repo.one(query) do
      nil -> {:ok, true}
      _ -> {:error, "Customer reward already queued up"}
    end
  end

  def redeem(customer_id, id) do
    query =
      from(r in CustomerReward,
        where: r.id == ^id and r.customer_id == ^customer_id and is_nil(r.redeemed)
      )

    case Repo.one(query) do
      nil ->
        {:error, "Customer reward not found or already redeemed"}

      customer_reward ->
        customer_reward
        |> change(%{redeemed: DateTime.utc_now()})
        |> Repo.update()
    end
  end

  def metrics_query(business_id, location_ids, period) do
    case period do
      :today ->
        from(r in CustomerReward,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                r.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
              r.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('hour', ? AT TIME ZONE (?->>'id' || ''))",
                r.redeemed,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_week ->
        from(r in CustomerReward,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('week', now() AT TIME ZONE (?->>'id' || '')) + interval '6 days 23 hours 59 minutes 59 seconds')",
                r.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              r.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                r.redeemed,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_month ->
        from(r in CustomerReward,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('month', now() AT TIME ZONE (?->>'id' || '')) + interval '1 month 23 hours 59 minutes 59 seconds' - interval '1 day')",
                r.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
              r.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('day', ? AT TIME ZONE (?->>'id' || ''))",
                r.redeemed,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_year ->
        from(r in CustomerReward,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                r.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              r.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                r.redeemed,
                l.timezone
              ),
            value: count(r.id)
          }
        )

      :this_year_to_date ->
        from(r in CustomerReward,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                r.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
              r.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('month', ? AT TIME ZONE (?->>'id' || ''))",
                r.redeemed,
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
        from(r in CustomerReward,
          join: l in assoc(r, :location),
          where:
            l.business_id == ^business_id and r.location_id in ^location_ids and
              fragment(
                "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', to_date('1970-01-01') AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
                r.redeemed,
                l.timezone,
                l.timezone,
                l.timezone
              ),
          group_by: [
            fragment(
              "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
              r.redeemed,
              l.timezone
            )
          ],
          select: %{
            id: fragment("row_number() OVER ()"),
            created:
              fragment(
                "DATE_PART('year', ? AT TIME ZONE (?->>'id' || ''))",
                r.redeemed,
                l.timezone
              ),
            value: count(r.id)
          }
        )
    end
  end

  defp last_num_days(business_id, location_ids, days, :day) do
    from(r in CustomerReward,
      join: l in assoc(r, :location),
      where:
        l.business_id == ^business_id and r.location_id in ^location_ids and
          r.redeemed > ago(^days, "day") and r.redeemed <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          r.redeemed,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('day', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            r.redeemed,
            l.timezone
          ),
        value: count(r.id)
      }
    )
  end

  defp last_num_days(business_id, location_ids, days, :month) do
    from(r in CustomerReward,
      join: l in assoc(r, :location),
      where:
        l.business_id == ^business_id and r.location_id in ^location_ids and
          r.redeemed > ago(^days, "day") and r.redeemed <= ^DateTime.utc_now(),
      group_by: [
        fragment(
          "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
          r.redeemed,
          l.timezone
        )
      ],
      select: %{
        id: fragment("row_number() OVER ()"),
        created:
          fragment(
            "EXTRACT(EPOCH from DATE_TRUNC('month', ? AT TIME ZONE (?->>'id' || ''))::timestamptz)::int",
            r.redeemed,
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

  def metrics_count(business_id, location_ids, period) do
    count =
      metrics_query(business_id, location_ids, period)
      |> Repo.all()
      |> Enum.reduce(0, fn r, acc -> r.value + acc end)

    {:ok, count}
  end

  def customers_hoarder_query(active_customer_ids, location_id) do
    # enough points on loyalty card to earn a reward
    # basically -> has loyalty rewards they haven't redeemed
    from(r in CustomerReward,
      join: c in assoc(r, :customer),
      join: l in assoc(r, :location),
      where:
        c.id in ^active_customer_ids and l.id == ^location_id and r.type == "loyalty" and
          is_nil(r.redeemed),
      distinct: c.id,
      select: c
    )
  end

  def customers_hoarder_count(active_customer_ids, location_id) do
    query = customers_hoarder_query(active_customer_ids, location_id)

    case Repo.aggregate(query, :count, :id) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def customers_spender_query(active_customer_ids, location_id) do
    from(r in CustomerReward,
      join: c in assoc(r, :customer),
      join: l in assoc(r, :location),
      group_by: [c.id, l.id, r.type],
      where:
        c.id in ^active_customer_ids and l.id == ^location_id and r.type == "loyalty" and
          not is_nil(r.redeemed),
      order_by: [desc: count("*")],
      limit: 100,
      select: c
    )
  end

  def customers_spender_count(active_customer_ids, location_id) do
    inner_query = customers_spender_query(active_customer_ids, location_id)

    query =
      from(c in subquery(inner_query),
        select: count("*")
      )

    case Repo.one(query) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def redemptions(customer_id, options) do
    from(r in CustomerReward,
      where: r.customer_id == ^customer_id and not is_nil(r.redeemed),
      order_by: [desc: r.redeemed]
    )
    |> paginate(options)
  end

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(queryset, _options) do
    queryset
    |> Repo.all()
  end

  def get_birthday_rewards(customer_id) do
    from(r in CustomerReward,
      join: l in assoc(r, :location),
      where:
        r.customer_id == ^customer_id and r.type == "birthday" and not is_nil(r.redeemed) and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
            r.inserted_at,
            l.timezone,
            l.timezone,
            l.timezone
          )
    )
    |> Repo.all()
  end

  def get_loyalty_reward_after_time_for_customer(epoch_time, customer_id, location_id) do
    time = DateTime.from_unix!(epoch_time, :millisecond)

    from(r in CustomerReward,
      join: l in assoc(r, :location),
      where:
        r.customer_id == ^customer_id and r.location_id == ^location_id and r.type == "loyalty" and
          fragment(
            "? AT TIME ZONE (?->>'id' || '') > ? AT TIME ZONE (?->>'id' || '')",
            r.inserted_at,
            l.timezone,
            ^time,
            l.timezone
          ),
      limit: 1
    )
    |> Repo.one()
  end

  def single_use_rewards(customer_id) do
    query =
      from(r in CustomerReward,
        join: reward in assoc(r, :reward),
        join: l in assoc(r, :location),
        where:
          r.customer_id == ^customer_id and
            ((not is_nil(r.redeemed) and reward.type == "facebook" and
                fragment(
                  "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                  r.inserted_at,
                  l.timezone,
                  l.timezone,
                  l.timezone
                )) or
               (not is_nil(r.redeemed) and reward.type == "birthday" and
                  fragment(
                    "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                    r.inserted_at,
                    l.timezone,
                    l.timezone,
                    l.timezone
                  ))),
        select: r.reward_id
      )

    case Repo.all(query) do
      {:error, error} -> {:error, error}
      result -> {:ok, result}
    end
  end

  def single_use_rewards_by_location(customer_id, location_id) do
    query =
      from(r in CustomerReward,
        join: reward in assoc(r, :reward),
        join: l in assoc(r, :location),
        where:
          r.customer_id == ^customer_id and r.location_id == ^location_id and
            ((not is_nil(r.redeemed) and reward.type == "facebook" and
                fragment(
                  "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + interval '23 hours 59 minutes 59 seconds')",
                  r.inserted_at,
                  l.timezone,
                  l.timezone,
                  l.timezone
                )) or
               (not is_nil(r.redeemed) and reward.type == "birthday" and
                  fragment(
                    "? AT TIME ZONE (?->>'id' || '') BETWEEN DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) AND (DATE_TRUNC('year', now() AT TIME ZONE (?->>'id' || '')) + interval '11 months 30 days 23 hours 59 minutes 59 seconds')",
                    r.inserted_at,
                    l.timezone,
                    l.timezone,
                    l.timezone
                  ))),
        select: r.reward_id
      )

    case Repo.all(query) do
      {:error, error} -> {:error, error}
      result -> {:ok, result}
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(reward_id customer_id location_id name type points expires redeemed)a)
    |> validate_required(~w(reward_id customer_id location_id name type points)a)
    |> foreign_key_constraint(:reward_id)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:location_id)
  end

  def get_reward(id) do
    query =
      from(r in CustomerReward,
        join: reward in assoc(r, :reward),
        preload: [reward: reward],
        where: r.id == ^id
      )

    case Repo.one(query) do
      nil -> {:error, "Customer Reward not found"}
      result -> {:ok, result}
    end
  end

  def get_rewards(customer_id) do
    from(r in CustomerReward,
      join: reward in assoc(r, :reward),
      preload: [reward: reward],
      where:
        r.customer_id == ^customer_id and (r.expires > ^DateTime.utc_now() or is_nil(r.expires)) and
          is_nil(r.redeemed)
    )
    |> Repo.all()
  end

  def get_rewards_by_location(customer_id, location_id) do
    from(r in CustomerReward,
      where:
        r.customer_id == ^customer_id and r.location_id == ^location_id and
          (r.expires > ^DateTime.utc_now() or is_nil(r.expires)) and is_nil(r.redeemed)
    )
    |> Repo.all()
  end
end
