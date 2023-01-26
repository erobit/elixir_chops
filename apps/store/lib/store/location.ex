defmodule Store.Location do
  use Store.Model
  import Geo.PostGIS

  @default_hours [
    %{weekday: "mon", start: "00:00", end: "00:00", closed: false},
    %{weekday: "tue", start: "00:00", end: "00:00", closed: false},
    %{weekday: "wed", start: "00:00", end: "00:00", closed: false},
    %{weekday: "thu", start: "00:00", end: "00:00", closed: false},
    %{weekday: "fri", start: "00:00", end: "00:00", closed: false},
    %{weekday: "sat", start: "00:00", end: "00:00", closed: false},
    %{weekday: "sun", start: "00:00", end: "00:00", closed: false}
  ]
  def default_hours, do: @default_hours

  @service_types ~w(atm credit debit accessible cash-only appointments-available)

  schema "locations" do
    field(:name, :string)
    field(:address, :string)
    field(:address_line2, :string)
    field(:city, :string)
    field(:province, :string)
    field(:postal_code, :string)
    field(:country, :string)
    field(:phone, :string)
    field(:email, :string)
    field(:phone_confirmed, :boolean)
    field(:email_confirmed, :boolean)
    field(:website_url, :string)
    field(:facebook_url, :string)
    field(:instagram_url, :string)
    field(:youtube_url, :string)
    field(:twitter_url, :string)
    field(:menu_url, :string)
    field(:about, :string)
    field(:hero, :string)
    field(:logo, :string)
    field(:point, Geo.PostGIS.Geometry)
    field(:polygon, Geo.PostGIS.Geometry)
    field(:service_types, {:array, :string})
    field(:is_active, :boolean)
    field(:is_member, :boolean, virtual: true)
    field(:notifications_enabled, :boolean, virtual: true)
    field(:qr_code, Ecto.UUID, autogenerate: true)
    field(:qr_budtender_scanning, :boolean, default: true)
    field(:tablet, :string)
    field(:tablet_background_color, :string)
    field(:tablet_background_image, :string)
    field(:tablet_foreground_color, :string)
    embeds_many(:hours, DailyHours, on_replace: :delete)
    embeds_one(:timezone, Timezone, on_replace: :delete)
    belongs_to(:business, Business)
    has_many(:deals, Deal)
    many_to_many(:employees, Employee, join_through: "employees_locations")
    has_many(:rewards, Reward)
    has_many(:memberships, MembershipLocation)
    has_many(:products, Product)
    has_one(:sms_settings, Store.Messaging.SMSSetting)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def get(id) do
    Location
    |> Repo.get(id)
  end

  def get_valid_employee_location_ids(employee) do
    get_valid_employee_locations_query(employee)
    |> select([:id])
    |> Repo.all()
    |> Enum.map(fn l -> l.id end)
  end

  def get_valid_employee_locations(employee) do
    get_valid_employee_locations_query(employee)
    |> Repo.all()
  end

  def get_valid_employee_locations_query(employee) do
    from(l in Location,
      where: l.business_id == ^employee.business_id and l.is_active
    )
    |> filter_for_employee(employee)
  end

  def get_offset(id) do
    location = get(id)
    location.timezone.raw_offset
  end

  def is_open(location_id) do
    query =
      from(l in Location,
        where:
          l.id == ^location_id and
            fragment(
              "hours->(extract(isodow from now() AT TIME ZONE (?->>'id' || ''))-1)::int->>'closed' = 'false' AND
          now() AT TIME ZONE (?->>'id' || '') BETWEEN 
          DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + (hours->(extract(isodow from now() AT TIME ZONE (?->>'id' || ''))-1)::int->>'start')::time - interval '15 minutes' AND
          DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')) + (hours->(extract(isodow from now() AT TIME ZONE (?->>'id' || ''))-1)::int->>'end')::time + interval '15 minutes'
          ",
              l.timezone,
              l.timezone,
              l.timezone,
              l.timezone,
              l.timezone,
              l.timezone
            )
      )

    case Repo.one(query) do
      nil ->
        {:error, "store_closed_cannot_earn_stamp"}

      _location ->
        {:ok, true}
    end
  end

  def get_store_page(id) do
    query =
      from(l in Location,
        join: b in assoc(l, :business),
        where: l.id == ^id and l.is_active and b.is_active,
        preload: [
          deals: ^filter_active_deals(),
          rewards: ^filter_active_rewards(),
          business: b
        ]
      )

    case Repo.one(query) do
      nil -> {:error, "Location #{id} does not exist or is inactive"}
      location -> {:ok, location |> filter_non_timely_deals() |> get_rating() |> put_conditions()}
    end
  end

  defp filter_for_employee(query, %{role: r}) when r in ["superadmin", "owner"] do
    query
  end

  defp filter_for_employee(query, %{role: r, locations: locations})
       when r in ["manager", "budtender"] do
    location_ids = Enum.map(locations, fn l -> l.id end)

    from(l in query,
      where: l.id in ^location_ids
    )
  end

  defp filter_active_deals() do
    from(d in Deal,
      where: d.is_active,
      order_by: [asc: d.expiry]
    )
  end

  defp filter_active_rewards() do
    from(r in Reward, where: r.is_active)
  end

  def get_by_business_id(business_id) do
    from(l in Location,
      where: l.business_id == ^business_id and l.is_active == true
    )
    |> Repo.all()
  end

  def get_by_tablet(business_id, tablet) do
    Location
    |> Repo.get_by(business_id: business_id, tablet: tablet)
  end

  def get_by_business_id(id, business_id) do
    Location
    |> preload(:sms_settings)
    |> Repo.get_by(id: id, business_id: business_id)
  end

  def get_active_by_business(business_id) do
    from(l in Location,
      where: l.business_id == ^business_id and l.is_active == true
    )
    |> Repo.all()
  end

  def get_by_business(business_id) do
    from(l in Location,
      where: l.business_id == ^business_id,
      select: l.id
    )
    |> Repo.all()
  end

  def get_timezone_ids(location_name) do
    from(l in Location,
      where: fragment("?->>? ILIKE ?", l.timezone, "name", ^"%#{location_name}%"),
      select: fragment("?->>?", l.timezone, "id")
    )
    |> Repo.all()
  end

  def get_locations(struct, key \\ :locations) do
    Map.get(struct, key, [])
    |> Location.get_by_ids()
  end

  def get_active_ids_by_business(business_id) do
    from(l in Location,
      where: l.business_id == ^business_id and l.is_active == true,
      select: l.id
    )
    |> Repo.all()
  end

  def get_active_locations(struct) do
    Map.get(struct, :locations, [])
    |> Location.get_by_ids_active()
  end

  def get_by_ids(ids) do
    from(l in Location,
      where: l.id in ^ids,
      preload: [deals: ^filter_active_deals(), rewards: ^filter_active_rewards()]
    )
    |> Repo.all()
    |> filter_non_timely_deals()
  end

  def get_by_ids_active(ids) do
    from(l in Location,
      where: l.id in ^ids and l.is_active == true,
      preload: [deals: ^filter_active_deals(), rewards: ^filter_active_rewards()]
    )
    |> Repo.all()
    |> filter_non_timely_deals()
  end

  defp get_rating(location) do
    l =
      from(l in Location,
        left_join: r in subquery(ratings_aggregate()),
        on: r.location_id == ^location.id,
        where: l.id == ^location.id and r.location_id == ^location.id,
        select: %{
          id: l.id,
          rating: r.rating,
          rating_count: r.count
        }
      )
      |> Repo.one()

    location
    |> Map.put(
      :rating,
      if l do
        l.rating
      end
    )
    |> Map.put(
      :rating_count,
      if l do
        l.rating_count
      end
    )
  end

  defp filter_non_timely_deals(locations) when is_list(locations) do
    locations |> Enum.map(&filter_non_timely_deals/1)
  end

  defp filter_non_timely_deals(location) when is_map(location) do
    filtered_deals =
      Enum.filter(location.deals, fn deal ->
        case is_nil(deal.expiry) do
          true ->
            true

          false ->
            now_in_timezone = Timex.now(location.timezone.id)
            start_of_expiry = Timex.beginning_of_day(deal.expiry)

            if is_nil(deal.end_time) do
              end_of_expiry = Timex.end_of_day(deal.expiry)
              compare_within_expiry = Timex.Comparable.compare(now_in_timezone, end_of_expiry)

              case compare_within_expiry == -1 do
                true -> true
                false -> false
              end
            else
              deal_end_time = Timex.add(start_of_expiry, Timex.Duration.from_time(deal.end_time))
              compare_end_time = Timex.Comparable.compare(now_in_timezone, deal_end_time)

              case compare_end_time != 1 do
                true -> true
                false -> false
              end
            end
        end
      end)

    Map.put(location, :deals, filtered_deals)
  end

  def get_locations_by_no_product_count(employee) do
    from(l in Location,
      left_join: p in assoc(l, :products),
      where: is_nil(p.id) and l.business_id == ^employee.business_id and l.is_active,
      select: %{
        id: l.id,
        name: l.name
      }
    )
    |> filter_for_employee(employee)
    |> Repo.all()
  end

  def get_all(business_id, location_ids, options) do
    Location
    |> where([l], l.business_id == ^business_id and l.id in ^location_ids)
    |> search(options)
    |> sort(options)
    |> filter(options)
    |> paginate(options)
  end

  def get_all(business_id, options) do
    Location
    |> where([l], l.business_id == ^business_id)
    |> search(options)
    |> sort(options)
    |> filter(options)
    |> paginate(options)
  end

  def get_all(options) do
    Location
    |> search(options)
    |> sort(options)
    |> filter(options)
    |> paginate(options)
  end

  def get_customers_unjoined_location_ids(customer_id, options) do
    query = get_joined_locations(customer_id)
    %{lat: lat, lng: lng, radius: radius} = options

    from(l in Store.Location,
      join: b in assoc(l, :business),
      left_join: ml in subquery(query),
      on: ml.location_id == l.id,
      where: is_nil(ml.customer_id) and l.is_active == true and b.is_active,
      select: [:id]
    )
    |> within(%{coordinates: %{lng: lng, lat: lat}, srid: 4326}, radius)
    |> Repo.all()
    |> Enum.map(fn l -> l.id end)
  end

  defp get_joined_locations(customer_id) do
    from(ml in Store.Loyalty.MembershipLocation,
      join: m in assoc(ml, :membership),
      join: b in assoc(m, :business),
      where: m.customer_id == ^customer_id and b.is_active,
      select: %{customer_id: m.customer_id, location_id: ml.location_id}
    )
  end

  # eventually add lat / lng here and postgis query
  def discover(options) do
    from(l in Location,
      join: b in assoc(l, :business),
      left_join: r in subquery(ratings_aggregate()),
      on: r.location_id == l.id,
      where: b.is_active and l.is_active and b.type == ^options.business_type,
      select: %{
        id: l.id,
        hero: l.hero,
        logo: l.logo,
        point: l.point,
        name: l.name,
        address: l.address,
        address_line2: l.address_line2,
        city: l.city,
        rating: r.rating,
        rating_count: r.count
      }
    )
    |> search(options)
    |> sort(options)
    |> filter(options)
    |> paginate(options)
  end

  defp search(query, %{options: %{search: name}}) do
    query |> where([l], ilike(l.name, ^"%#{name}%"))
  end

  defp search(query, _options), do: query

  defp sort(query, %{options: %{sort: %{field: fieldname, order: order}}}) do
    direction = if order == 1, do: :asc, else: :desc
    query |> order_by([l], [{^direction, field(l, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _options), do: query

  defp filter(query, %{lng: lng, lat: lat, radius: radius, options: options}) do
    query
    |> within(%{coordinates: %{lng: lng, lat: lat}, srid: 4326}, radius)
  end

  defp filter(query, %{options: %{filters: filters}}) do
    active_filter = find_filter(filters, "is_active")

    query
    |> filter_active(active_filter)
  end

  defp filter(query, _options), do: query

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_active(query, nil), do: query

  defp filter_active(query, %{args: args, field: _}) do
    case args do
      [] -> query
      ["true"] -> from(e in query, where: e.is_active == true)
      ["false"] -> from(e in query, where: e.is_active == false)
      _ -> query
    end
  end

  defp ratings_aggregate() do
    from(r in Review,
      join: reward in "rewards",
      on: reward.location_id == r.location_id and reward.type == "review" and reward.is_active,
      where: r.completed,
      group_by: [r.location_id],
      select: %{
        location_id: r.location_id,
        rating: avg(r.rating),
        count: count("*")
      }
    )
  end

  @doc """
  Builds a changeset based on 'struct' and 'params'
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      ~w(business_id name address address_line2 city province postal_code country phone email
        website_url facebook_url instagram_url youtube_url twitter_url menu_url
        about hero logo point polygon service_types qr_code is_active tablet
        tablet_background_image tablet_background_color tablet_foreground_color qr_budtender_scanning)a
    )
    |> put_embed(:hours, parse_hours(params))
    |> put_embed(:timezone, parse_timezone(params))
    |> put_sms_settings(params)
    |> validate_required(~w(business_id name address city province postal_code country
        phone hero logo point polygon service_types)a)
    |> validate_subset(:service_types, @service_types)
    |> foreign_key_constraint(:business_id)
    |> unique_constraint(:business_and_tablet, name: :locations_business_id_tablet_index)
  end

  defp put_sms_settings(changeset, params) do
    case Map.get(params, :sms_settings, nil) do
      nil -> changeset
      settings -> changeset |> put_assoc(:sms_settings, settings)
    end
  end

  def phone_confirmed(id, is_confirmed) do
    Location
    |> Repo.get(id)
    |> change(%{phone_confirmed: is_confirmed})
    |> Repo.update()
  end

  def email_confirmed(id, is_confirmed) do
    Location
    |> Repo.get(id)
    |> change(%{email_confirmed: is_confirmed})
    |> Repo.update()
  end

  def toggle_active(id, is_active) do
    Location
    |> Repo.get(id)
    |> change(%{is_active: is_active})
    |> Repo.update()
  end

  def change_hours(id, hours) do
    Location
    |> Repo.get(id)
    |> change(%{hours: hours})
    |> Repo.update()
  end

  ########################
  # Geo / postgis queries
  ########################

  def within(query, point, radius_in_m) do
    lat = Map.get(point.coordinates, :lat)
    lng = Map.get(point.coordinates, :lng)

    from(location in query,
      where:
        fragment(
          "ST_DWithin(?::geography, ST_SetSRID(ST_MakePoint(?, ?), ?), ?)",
          location.point,
          ^lng,
          ^lat,
          ^point.srid,
          ^radius_in_m
        )
    )
  end

  def order_by_nearest(query, point) do
    {lng, lat} = point.coordinates

    from(location in query,
      order_by:
        fragment(
          "? <-> ST_SetSRID(ST_MakePoint(?,?), ?)",
          location.point,
          ^lng,
          ^lat,
          ^point.srid
        )
    )
  end

  def select_with_distance(query, point) do
    {lng, lat} = point.coordinates

    from(location in query,
      select: %{
        location
        | distance:
            fragment(
              "ST_Distance_Sphere(?, ST_SetSRID(ST_MakePoint(?,?), ?))",
              location.point,
              ^lng,
              ^lat,
              ^point.srid
            )
      }
    )
  end

  def find_intersection(lat, lng) do
    point = %Geo.Point{coordinates: {lng, lat}, srid: 4326}

    query =
      from(l in Location,
        join: b in assoc(l, :business),
        where: b.is_active and l.is_active and st_intersects(^point, l.polygon)
      )

    case Repo.all(query) do
      {:error, error} -> {:error, error}
      locations -> {:ok, locations}
    end
  end

  def validate_qr_code(location_id, qr_code) do
    with {:ok, qr_code} <- Ecto.UUID.cast(qr_code) do
      query =
        from(l in Location,
          join: b in assoc(l, :business),
          where: l.id == ^location_id and l.qr_code == ^qr_code and b.is_active == true
        )

      case Repo.one(query) do
        nil -> {:error, "QR code for location did not match"}
        _ -> {:ok, true}
      end
    else
      _ -> {:error, "QR code for location did not match"}
    end
  end

  def get_qr_code(location_id) do
    case get(location_id) do
      nil -> {:error, "Location not found"}
      location -> {:ok, %{qr_code: location.qr_code}}
    end
  end

  def set_qr_code(location_id) do
    get(location_id)
    |> change(%{qr_code: Ecto.UUID.generate()})
    |> Repo.update()
  end

  ####################
  # Private functions
  ####################

  defp insert(struct) do
    struct = struct |> generate_qr_code()

    %Location{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp generate_qr_code(struct) do
    struct |> Map.put(:qr_code, Ecto.UUID.generate())
  end

  defp update(struct) do
    Location
    |> preload(:sms_settings)
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp parse_hours(params) do
    Map.get(params, :hours, @default_hours)
    |> Enum.map(&DailyHours.create/1)
  end

  defp parse_timezone(params) do
    Map.get(params, :timezone, %{})
    |> Timezone.create()
  end

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(queryset, _options) do
    queryset
    |> Repo.all()
  end
end
