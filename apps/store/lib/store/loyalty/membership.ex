defmodule Store.Loyalty.Membership do
  use Store.Model

  schema "memberships" do
    belongs_to(:business, Store.Business)
    belongs_to(:customer, Store.Customer)

    # @TODO - can we replace this with a many_to_many join_through our custom table/schema
    # so that we can join on Store.Locations properly but still have the is_active bool
    # should allow us to remove all the fuckery with the functions below I believe
    # , Store.Location, join_through: :membership_locations
    has_many(:locations, Store.Loyalty.MembershipLocation)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %Membership{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def get_by_customer_and_business(customer_id, business_id) do
    Membership
    |> Repo.get_by(customer_id: customer_id, business_id: business_id)
  end

  def get_by_customer(customer_id) do
    memberships =
      from(m in Membership,
        join: b in assoc(m, :business),
        where: m.customer_id == ^customer_id and b.is_active == true,
        preload: [locations: ^only_active_locations()],
        select: m
      )
      |> Repo.all()
      |> populate_locations()

    {:ok, memberships}
  end

  defp only_active_locations() do
    from(l in MembershipLocation,
      where: l.is_active == true
    )
  end

  defp populate_locations(memberships) do
    locations = memberships |> Enum.flat_map(&grab_location_ids/1)

    memberships
    |> set_locations(locations)
  end

  defp grab_location_ids(membership) do
    membership.locations
    |> Enum.map(fn l -> l.location_id end)
    |> Location.get_by_ids_active()
    |> Enum.into([], fn l -> %{"key" => l.id, "value" => l} end)
  end

  defp set_locations(memberships, locations) do
    memberships
    |> Enum.map(fn m -> set_location_ids(m, locations) end)
  end

  defp set_location_ids(membership, locations) do
    # exclude any membership_locations not in active locations
    only_active_locations =
      Enum.filter(membership.locations, fn l ->
        l3 =
          Enum.find(locations, fn l2 ->
            l2["key"] == l.location_id
          end)

        l3 != nil
      end)

    membership = Map.put(membership, :locations, only_active_locations)

    new_locations =
      Enum.map(membership.locations, fn l ->
        l3 =
          Enum.find(locations, fn l2 ->
            l2["key"] == l.location_id
          end)

        Map.put(l3["value"], :notifications_enabled, l.notifications_enabled)
      end)

    Map.put(membership, :locations, new_locations)
  end

  def customers_all_query(active_customer_ids) do
    from(m in Membership,
      join: c in assoc(m, :customer),
      where: c.id in ^active_customer_ids,
      distinct: c.id,
      select: c
    )
  end

  def customers_all_count(active_customer_ids) do
    query = customers_all_query(active_customer_ids)

    case Repo.aggregate(query, :count, :id) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def customers_birthday_query(active_customer_ids) do
    today = Timex.now()

    from(m in Membership,
      join: c in assoc(m, :customer),
      where:
        c.id in ^active_customer_ids and
          fragment("date_part('month', ?)", c.birthdate) == ^today.month,
      distinct: c.id,
      select: c
    )
  end

  def customers_birthday_count(active_customer_ids) do
    query = customers_birthday_query(active_customer_ids)

    case Repo.aggregate(query, :count, :id) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(business_id customer_id)a)
    |> put_assoc(:locations, Location.get_locations(params))
    |> validate_required(~w(business_id customer_id)a)
    |> unique_constraint(:business_id, name: :members_business_id_customer_id_index)
    |> foreign_key_constraint(:business_id)
    |> foreign_key_constraint(:customer_id)
  end

  def delete(customer_id) do
    statement =
      from(m in Membership,
        where: m.customer_id == ^customer_id
      )

    case Repo.delete_all(statement) do
      {num_results, nil} -> {:ok, num_results}
      _ -> {:error, "could_not_delete_memberships"}
    end
  end
end
