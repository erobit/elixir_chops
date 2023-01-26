defmodule Store.Customer do
  use Store.Model
  alias Store.Utility.KeywordListToMap, as: KeywordListToMap

  @experience_levels ~w(daily_usage weekly_usage monthly_usage past_usage no_experience)

  schema "customers" do
    field(:phone, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:gender, :string)
    field(:email, :string)
    field(:email_verified, :boolean)
    field(:avatar, :string)
    field(:qr_code, Ecto.UUID, autogenerate: true)
    field(:birthdate, :date)
    field(:birthdate_verified, :boolean)
    field(:notifications_enabled, :boolean)
    field(:facebook_token, :string)
    field(:facebook_id, :string)
    field(:fcm_token, :string)
    field(:experience_level, :string)
    field(:deleted, :boolean)
    has_many(:visits, Store.Visit)
    has_many(:memberships, Store.Loyalty.Membership)
    has_many(:transactions, Store.Loyalty.Transaction)

    many_to_many(:categories, Store.Inventory.Category,
      join_through: "customers_categories",
      on_replace: :delete
    )

    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def create_sanitized(struct) do
    %Customer{}
    |> changeset(struct)
    |> Repo.insert()
    |> sanitize()
  end

  def get(id) do
    Customer
    |> preload(:categories)
    |> Repo.get(id)
  end

  def get_profile(id) do
    from(c in Customer,
      left_join: cat in subquery(categories_aggregate(id)),
      on: cat.customer_id == ^id,
      left_join: el in subquery(employee_locations_aggregate(id)),
      on: el.customer_id == ^id,
      where: c.id == ^id and c.deleted == false,
      select: %{
        id: c.id,
        gender: c.gender,
        phone: c.phone,
        email: c.email,
        email_verified: c.email_verified,
        avatar: c.avatar,
        first_name: c.first_name,
        last_name: c.last_name,
        qr_code: c.qr_code,
        birthdate: c.birthdate,
        notifications_enabled: c.notifications_enabled,
        fcm_token: c.fcm_token,
        categories: cat.categories,
        employee_locations: el.locations,
        experience_level: c.experience_level
      }
    )
    |> Repo.one()
    |> convert_customer_categories_keyword_list_to_map()
    |> convert_employee_locations_keyword_list_to_map()
  end

  # Could be de-duped by segment query reusage
  def get_details(id, location_id) do
    from(c in Customer,
      join: m in assoc(c, :memberships),
      join: ml in assoc(m, :locations),
      join: l in assoc(ml, :location),
      left_join: cat in subquery(categories_aggregate(id)),
      on: cat.customer_id == ^id,
      left_join: v in subquery(visit_aggregate(id, location_id)),
      on: v.customer_id == ^id and v.location_id == ^location_id,
      left_join: t in subquery(transaction_aggregate(id, location_id)),
      on: t.customer_id == ^id and t.location_id == ^location_id,
      left_join: r in subquery(customer_rewards_aggregate(id, location_id)),
      on: r.customer_id == ^id and r.location_id == ^location_id,
      left_join: p in subquery(customer_products_aggregate(id, location_id)),
      on: p.customer_id == ^id and p.location_id == ^location_id,
      where: c.id == ^id and ml.location_id == ^location_id and c.deleted == false,
      select: %{
        id: c.id,
        first_name: c.first_name,
        last_name: c.last_name,
        birthdate: c.birthdate,
        birthdate_verified: c.birthdate_verified,
        avatar: c.avatar,
        phone: c.phone,
        qr_code: c.qr_code,
        last_visit: v.last_visit,
        first_visit: v.first_visit,
        visits: coalesce(v.count, 0),
        stamps: coalesce(t.total, 0),
        rewards_claimed: coalesce(r.claimed, 0),
        rewards_unclaimed: coalesce(r.unclaimed, 0),
        categories: cat.categories,
        products: p.products,
        notifications_enabled: ml.notifications_enabled,
        opted_out: ml.opted_out
      }
    )
    |> Repo.one()
    |> convert_customer_categories_keyword_list_to_map()
    |> convert_customer_products_keyword_list_to_map()
  end

  def get_fcm_tokens(ids) do
    from(c in Customer,
      where: c.id in ^ids and not is_nil(c.fcm_token) and c.deleted == false,
      select: [:fcm_token]
    )
    |> Repo.all()
    |> Enum.map(fn c -> c.fcm_token end)
  end

  def get_by_phone(phone) do
    Customer
    |> Repo.get_by(phone: phone, deleted: false)
    |> sanitize()
  end

  def get_by_qr_code(qr_code) do
    Customer
    |> Repo.get_by(qr_code: qr_code, deleted: false)
  end

  def get_by_phone_unsanitized(phone) do
    Customer
    |> Repo.get_by(phone: phone, deleted: false)
  end

  def get_customers(struct) do
    Map.get(struct, :customers, [])
    |> Customer.get_by_ids()
  end

  def get_by_ids(ids) do
    from(c in Customer,
      where: c.id in ^ids and c.deleted == false
    )
    |> Repo.all()
  end

  def get_by_phone_or_email(phone, email) do
    from(customer in Customer,
      where:
        customer.deleted == false and
          (customer.phone == ^phone or customer.email == ^String.downcase(email))
    )
    |> Repo.one()
  end

  def get_by_facebook_id(facebook_id) do
    Customer
    |> Repo.get_by(facebook_id: facebook_id, deleted: false)
    |> sanitize()
  end

  def get_by_phone_verified(phone) do
    from(customer in Customer,
      where: customer.phone == ^phone and customer.email_verified and customer.deleted == false
    )
    |> Repo.one()
  end

  def get_by_email_verified(email) do
    from(customer in Customer,
      where:
        customer.email == ^String.downcase(email) and customer.email_verified and
          customer.deleted == false
    )
    |> Repo.one()
  end

  def get_sanitized(id) do
    Customer.get(id)
    |> sanitize()
  end

  defp insert(struct) do
    %Customer{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Customer
    |> Repo.get(struct.id)
    |> Repo.preload(:categories)
    |> update_changeset(struct)
    |> invalidate_email()
    |> Repo.update()
  end

  def set_email_verified(phone, email, verified) do
    query =
      Customer
      |> Repo.get_by(phone: phone, deleted: false)

    case query do
      nil ->
        {:error, "customer_with_phone_does_not_exist"}

      customer ->
        customer
        |> change(%{email: String.downcase(email), email_verified: verified})
        |> Repo.update()
    end
  end

  def recover(old_phone, new_phone) do
    query =
      Customer
      |> Repo.get_by(phone: old_phone, deleted: false)

    case query do
      nil ->
        {:error, "customer_with_phone_does_not_exist"}

      customer ->
        customer
        |> change(%{phone: new_phone})
        |> Repo.update()
    end
  end

  ########################
  # Aggregate Subqueries #
  ########################

  defp visit_aggregate(customer_id, location_id) do
    from(v in visit_aggregate(),
      where: v.customer_id == ^customer_id and v.location_id == ^location_id
    )
  end

  defp visit_aggregate() do
    from(v in Visit,
      group_by: [v.customer_id, v.location_id],
      select: %{
        customer_id: v.customer_id,
        location_id: v.location_id,
        count: count("*"),
        last_visit: max(v.inserted_at),
        first_visit: min(v.inserted_at)
      }
    )
  end

  defp transaction_aggregate(customer_id, location_id) do
    from(t in transaction_aggregate(),
      where: t.customer_id == ^customer_id and t.location_id == ^location_id
    )
  end

  defp transaction_aggregate do
    from(t in Transaction,
      group_by: [t.customer_id, t.location_id],
      select: %{
        customer_id: t.customer_id,
        location_id: t.location_id,
        total:
          sum(
            fragment(
              "CASE WHEN ? THEN ? ELSE ? END",
              t.type == "credit",
              t.units,
              0 - t.units
            )
          )
      }
    )
  end

  defp categories_aggregate(id) do
    query = categories_aggregate()
    from(c in query, where: c.id == ^id)
  end

  defp categories_aggregate do
    from(c in Customer,
      join: cat in assoc(c, :categories),
      group_by: c.id,
      select: %{
        customer_id: c.id,
        categories:
          fragment(
            """
              json_agg(
                json_build_object('id', ?, 'name', ?)
              )
            """,
            cat.id,
            cat.name
          )
      }
    )
  end

  defp customer_rewards_aggregate(customer_id, location_id) do
    from(r in customer_rewards_aggregate(),
      where: r.customer_id == ^customer_id and r.location_id == ^location_id
    )
  end

  defp customer_rewards_aggregate() do
    from(r in CustomerReward,
      group_by: [r.customer_id, r.location_id],
      select: %{
        customer_id: r.customer_id,
        location_id: r.location_id,
        claimed:
          sum(
            fragment(
              "CASE WHEN ? THEN ? ELSE ? END",
              not is_nil(r.redeemed),
              1,
              0
            )
          ),
        unclaimed:
          sum(
            fragment(
              "CASE WHEN ? THEN ? ELSE ? END",
              is_nil(r.redeemed) and (is_nil(r.expires) or r.expires > fragment("now()")),
              1,
              0
            )
          )
      }
    )
  end

  defp customer_products_aggregate() do
    from(p in Product,
      join: cp in CustomerProduct,
      on: cp.product_id == p.id,
      join: c in Customer,
      on: cp.customer_id == c.id,
      group_by: [c.id, p.location_id],
      select: %{
        customer_id: c.id,
        location_id: p.location_id,
        products: fragment("json_agg(DISTINCT ?)", p)
      }
    )
  end

  defp customer_products_aggregate(customer_id, location_id) do
    from(p in customer_products_aggregate(),
      join: cp in CustomerProduct,
      on: cp.product_id == p.id,
      join: c in Customer,
      on: cp.customer_id == c.id,
      where: c.id == ^customer_id and p.location_id == ^location_id
    )
  end

  defp employee_locations_aggregate(customer_id) do
    from(l in Location,
      join: e in Employee,
      on: e.business_id == l.business_id,
      join: c in Customer,
      on: e.phone == c.phone and e.is_active and not e.is_deleted and c.id == ^customer_id,
      join: b in Business,
      on: l.business_id == b.id and b.type == "xyz",
      left_join: el in "employees_locations",
      on: el.location_id == l.id,
      where:
        c.deleted == false and l.qr_budtender_scanning and l.is_active and
          (e.role == "owner" or (e.role != "owner" and e.id == el.employee_id)),
      group_by: [c.id],
      select: %{
        customer_id: c.id,
        locations: fragment("json_agg(DISTINCT ?)", l)
      }
    )
  end

  def segment(query, options, _business_id, location_id) do
    from(c in Customer,
      join: c2 in subquery(query),
      on: c2.id == c.id,
      join: m in assoc(c, :memberships),
      join: ml in assoc(m, :locations),
      join: l in assoc(ml, :location),
      left_join: t in subquery(transaction_aggregate()),
      on: c.id == t.customer_id and ^location_id == t.location_id,
      left_join: v in subquery(visit_aggregate()),
      on: c.id == v.customer_id and ^location_id == v.location_id,
      left_join: cat in subquery(categories_aggregate()),
      on: c.id == cat.customer_id,
      where:
        l.is_active and ml.is_active and ml.location_id == ^location_id and c.deleted == false,
      select: %{
        id: c.id,
        first_name: c.first_name,
        last_name: c.last_name,
        phone: c.phone,
        stamps: coalesce(t.total, 0),
        visits: coalesce(v.count, 0),
        last_visit: v.last_visit,
        notifications_enabled: ml.notifications_enabled,
        opted_out: ml.opted_out,
        categories: cat.categories
      }
    )
    |> filter(options)
    |> search(options)
    |> sort(%{location_id: location_id, options: options.options})
    |> paginate(options)
    |> convert_customers_categories_keyword_list_to_map()
  end

  defp convert_customers_categories_keyword_list_to_map({:ok, page}) do
    entries = convert_customers_categories_keyword_list_to_map(page.entries)
    page = Map.put(page, :entries, entries)
    {:ok, page}
  end

  defp convert_customers_categories_keyword_list_to_map(customers) do
    Enum.map(customers, &convert_customer_categories_keyword_list_to_map/1)
  end

  defp convert_customer_categories_keyword_list_to_map(customer) do
    categories =
      case customer.categories do
        nil ->
          []

        _ ->
          Enum.map(Map.get(customer, :categories, []), fn category ->
            KeywordListToMap.convert_keyword_list_to_map(category)
          end)
      end

    Map.put(customer, :categories, categories)
  end

  defp convert_customer_products_keyword_list_to_map(customer) do
    products =
      case customer.products do
        nil ->
          []

        _ ->
          Enum.map(Map.get(customer, :products, []), fn product ->
            KeywordListToMap.convert_keyword_list_to_map(product)
          end)
      end

    Map.put(customer, :products, products)
  end

  defp convert_employee_locations_keyword_list_to_map(customer) do
    employee_locations =
      case customer.employee_locations do
        nil ->
          []

        _ ->
          Enum.map(Map.get(customer, :employee_locations, []), fn el ->
            KeywordListToMap.convert_keyword_list_to_map(el)
          end)
      end

    Map.put(customer, :employee_locations, employee_locations)
  end

  def campaign_segment(query, options) do
    from(c in subquery(query),
      preload: [:categories],
      select: c
    )
    |> filter(options)
    |> Repo.all()
  end

  defp search(query, %{options: %{search: name}}) do
    query
    |> where(
      [c],
      ilike(c.first_name, ^"%#{name}%") or ilike(c.last_name, ^"%#{name}%") or
        ilike(c.phone, ^"%#{name}%") or ilike(c.email, ^"%#{name}%")
    )
  end

  defp search(query, _options), do: query

  defp get_direction(1), do: :asc

  defp get_direction(_), do: :desc

  defp sort(query, %{
         location_id: _location_id,
         options: %{sort: %{field: "sms_status", order: order}}
       }) do
    direction = get_direction(order)

    from(c in query,
      join: m in assoc(c, :memberships),
      join: ml in assoc(m, :locations),
      order_by: [{^direction, ml.notifications_enabled}]
    )
  end

  defp sort(query, %{
         location_id: location_id,
         options: %{sort: %{field: "last_visit", order: order}}
       }) do
    direction = get_direction(order)

    from(c in query,
      left_join: v in subquery(visit_aggregate()),
      on: c.id == v.customer_id and ^location_id == v.location_id,
      order_by: [{^direction, coalesce(v.last_visit, fragment("make_date(1970, 1, 1)"))}]
    )
  end

  defp sort(query, %{
         location_id: location_id,
         options: %{sort: %{field: "count", order: order}}
       }) do
    direction = get_direction(order)

    from(c in query,
      left_join: v in subquery(visit_aggregate()),
      on: c.id == v.customer_id and ^location_id == v.location_id,
      order_by: [{^direction, coalesce(v.count, 0)}]
    )
  end

  defp sort(query, %{
         location_id: location_id,
         options: %{sort: %{field: "balance", order: order}}
       }) do
    direction = get_direction(order)

    from(c in query,
      left_join: t in subquery(transaction_aggregate()),
      on: c.id == t.customer_id and ^location_id == t.location_id,
      order_by: [{^direction, coalesce(t.total, 0)}]
    )
  end

  defp sort(query, %{options: %{sort: %{field: fieldname, order: order}}}) do
    direction = get_direction(order)
    query |> order_by([c], [{^direction, field(c, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _options), do: query

  defp filter(query, %{options: %{filters: filters}}) do
    category_filter = find_filter(filters, "category_id")

    query
    |> filter_categories(category_filter)
  end

  defp filter(query, _options), do: query

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_categories(query, nil), do: query

  defp filter_categories(query, %{args: args, field: _}) do
    # ids = Enum.map(args, &String.to_integer/1)
    from(c in query,
      left_join: cat in assoc(c, :categories),
      where: cat.id in ^args or is_nil(cat.id)
    )
  end

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(queryset, _options) do
    queryset
    |> Repo.all()
  end

  # This is a private method used when authenticating and when serializing for
  # the jwt token during authentication to ensure only a limited and secure
  # fieldset is returned and stored within the jwt. We could expand this
  # to include locations and other relevant information in the future but it's
  # probably better to query it as it could change often.
  defp sanitize(nil), do: {:error, "Customer not found"}

  defp sanitize(customer) do
    case customer do
      {:error, err} -> {:error, err}
      {:ok, customer} -> {:ok, customer |> Map.take([:__meta__, :__struct__, :id])}
      customer -> {:ok, customer |> Map.take([:__meta__, :__struct__, :id])}
    end
  end

  def add_category_id_to_favourites(customer_id, category_id) do
    Ecto.Adapters.SQL.query!(
      Store.Repo,
      "INSERT INTO customers_categories (customer_id, category_id) VALUES ($1, $2);",
      [customer_id, category_id]
    )
  end

  @doc """
  Builds a changeset based on 'struct' and 'params'
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(phone first_name last_name email avatar
        birthdate notifications_enabled facebook_token facebook_id
        gender birthdate_verified 
        experience_level deleted)a)
    |> put_assoc(:categories, Category.get_categories(params))
    |> validate_required(~w(phone)a)
    |> validate_inclusion(:experience_level, @experience_levels)
    |> unique_constraint(:phone, name: "customers_phone_index")
    |> unique_constraint(:email, name: "customers_email_index")
    |> downcase_email()
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(first_name last_name email avatar
        birthdate notifications_enabled facebook_token facebook_id experience_level
         gender birthdate_verified deleted)a)
    |> put_assoc(:categories, Category.get_categories(struct, params))
    |> validate_inclusion(:experience_level, @experience_levels)
    |> unique_constraint(:email, name: "customers_email_index")
    |> downcase_email()
  end

  def downcase_email(changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end

  defp invalidate_email(changeset) do
    case fetch_change(changeset, :email) do
      :error -> changeset
      _ -> put_change(changeset, :email_verified, false)
    end
  end

  def no_show_query(active_customer_ids, active_business_locations) do
    from(c in Customer,
      where:
        c.deleted == false and c.id in ^active_customer_ids and
          fragment(
            "? NOT IN (SELECT DISTINCT customer_id FROM visits WHERE customer_id = ANY(SELECT unnest(?::int[])) AND location_id = ANY(SELECT unnest(?::int[])) )",
            c.id,
            ^active_customer_ids,
            ^active_business_locations
          ),
      select: c
    )
  end

  def lapsed_query(active_customer_ids, location_id) do
    # customer has visited this shop but not in the past 5 weeks
    five_weeks_ago = Timex.shift(Timex.now(), weeks: -5)
    five_weeks_ago = Timex.beginning_of_day(five_weeks_ago)

    from(c in Customer,
      join: v in assoc(c, :visits),
      where:
        c.deleted == false and c.id in ^active_customer_ids and v.customer_id == c.id and
          v.location_id == ^location_id and v.inserted_at < ^five_weeks_ago and
          fragment(
            "NOT EXISTS(SELECT id FROM visits WHERE customer_id = ? and location_id = ? and inserted_at >= ?)",
            c.id,
            v.location_id,
            ^five_weeks_ago
          ),
      distinct: c.id,
      select: c
    )
  end

  def lapsed_count(active_customer_ids, location_id) do
    query = lapsed_query(active_customer_ids, location_id)

    case Repo.aggregate(query, :count, :id) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def no_show_count(active_customer_ids, active_business_locations) do
    inner_query = no_show_query(active_customer_ids, active_business_locations)

    query =
      from(c in subquery(inner_query),
        select: count("*")
      )

    case Repo.one(query) do
      {:error, _} -> {:error, "Error querying metrics"}
      metrics -> {:ok, metrics}
    end
  end

  def delete(id) do
    scrubbed = %{
      deleted: true,
      phone: Ecto.UUID.generate(),
      email: nil,
      avatar: nil,
      facebook_token: nil,
      birthdate: nil,
      first_name: nil,
      last_name: nil,
      facebook_id: nil,
      notifications_enabled: false,
      birthdate_verified: false,
      email_verified: false,
      experience_level: nil
    }

    Customer
    |> Repo.get(id)
    |> change(scrubbed)
    |> Repo.update()
  end

  # only used on custom customer paged object
  defimpl CSV.Encode, for: Customer do
    def encode(c, env \\ []) do
      [c.id, c.phone, c.first_name, c.last_name, c.email, c.stamps, c.visits, c.last_visit]
      |> Enum.map(fn v -> CSV.Encode.encode(v, env) end)
      |> Enum.join(",")
    end
  end
end
