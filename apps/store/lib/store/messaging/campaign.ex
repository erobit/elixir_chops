defmodule Store.Messaging.Campaign do
  use Store.Model

  schema "campaigns" do
    field(:message, :string)
    field(:send_now, :boolean)
    field(:scheduled, :boolean)
    field(:sent, :boolean)
    field(:is_active, :boolean)
    field(:send_date, :date)
    field(:send_time, :time)
    field(:timezone, :string)
    belongs_to(:business, Store.Business)
    belongs_to(:location, Store.Location)
    belongs_to(:deal, Store.Loyalty.Deal)
    belongs_to(:survey, Store.Survey)

    many_to_many(:groups, Store.Loyalty.MemberGroup,
      join_through: "campaigns_groups",
      on_replace: :delete
    )

    many_to_many(:categories, Store.Inventory.Category,
      join_through: "campaigns_categories",
      on_replace: :delete
    )

    many_to_many(:customers, Store.Customer,
      join_through: "campaigns_customers",
      on_replace: :delete
    )

    many_to_many(:products, Store.Inventory.Product,
      join_through: "campaigns_products",
      on_replace: :delete
    )

    has_many(:events, Store.Messaging.CampaignEvent)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  # @TODO - Consider batching - we should instead send messages individually
  # within each applicable timezone on a schedule for more precision and fidelity
  def ready_to_send(timezone_ids, schedule_date_time) do
    local_date = Timex.to_date(schedule_date_time)

    {:ok, local_time} =
      schedule_date_time
      |> Calendar.Strftime.strftime!("%H:%M:00")
      |> Time.from_iso8601()

    query =
      from(c in Campaign,
        where:
          c.timezone in ^timezone_ids and c.send_now == false and c.send_date == ^local_date and
            c.send_time == ^local_time and c.sent == false,
        preload: [:location, :groups, :categories, :deal, :survey, :products]
      )

    case Repo.all(query) do
      {:error, error} -> {:error, error}
      results -> {:ok, sanitize_for_sending(results)}
    end
  end

  defp sanitize_for_sending(campaigns) do
    Enum.map(campaigns, fn campaign ->
      groups = Enum.map(campaign.groups, fn group -> group.id end)
      categories = Enum.map(campaign.categories, fn cat -> cat.id end)
      products = Enum.map(campaign.products, fn prod -> prod.id end)

      campaign
      |> Map.put(:groups, groups)
      |> Map.put(:categories, categories)
      |> Map.put(:products, products)
      # hack to send now
      |> Map.put(:send_now, true)
      |> Map.take([
        :id,
        :message,
        :business_id,
        :groups,
        :categories,
        :location,
        :location_id,
        :products,
        :send_now,
        :deal,
        :survey
      ])
    end)
  end

  def get(id) do
    Campaign
    |> preload(:location)
    |> preload(:groups)
    |> preload(:categories)
    |> preload(:deal)
    |> preload(:products)
    |> preload(:survey)
    |> Repo.get(id)
  end

  def get_by_business_id(business_id, id) do
    query =
      from(c in Campaign,
        where: c.business_id == ^business_id and c.id == ^id and c.is_active == true,
        preload: [:location, :groups, :categories, :products]
      )

    case Repo.one(query) do
      nil -> {:error, "Campaign not found"}
      campaign -> {:ok, campaign}
    end
  end

  # @TODO - need to aggregate reach bounce, clicks and calculate ctr
  # and store on virtual fields
  def get_all(business_id, location_id, options) do
    Campaign
    |> filter(options)
    |> where(
      [c],
      c.business_id == ^business_id and c.is_active == true and c.location_id == ^location_id
    )
    |> order_by([c], asc: c.send_date, asc: c.send_time)
    |> preload(:groups)
    |> preload(:events)
    |> preload(:customers)
    |> preload(:location)
    |> preload(:deal)
    |> preload(:survey)
    |> preload(:products)
    |> paginate(options)
    |> aggregate()
  end

  defp aggregate({:ok, page}) do
    # aggregate the stamp count and the visit count and append last visit
    campaigns_aggregated =
      Enum.map(page.entries, fn campaign ->
        clicks =
          Enum.count(campaign.events, fn e -> e.type == "click" or e.type == "survey-click" end)

        bounces = Enum.count(campaign.events, fn e -> e.type == "bounce" end)
        reach = length(campaign.customers)
        ctr = if reach == 0, do: 0, else: clicks / reach * 100

        visits = Visit.count_by_campaign(campaign)

        campaign
        |> Map.delete(:events)
        |> Map.delete(:customers)
        |> Map.put(:clicks, clicks)
        |> Map.put(:bounces, bounces)
        |> Map.put(:reach, reach)
        |> Map.put(:ctr, ctr)
        |> Map.put(:visits, visits)
      end)

    page = Map.put(page, :entries, campaigns_aggregated)
    {:ok, page}
  end

  defp aggregate(result), do: result

  def changeset(struct, params \\ %{}) do
    customers = Map.get(params, :customers, [])
    customers = Enum.map(customers, fn c -> c.id end)
    params = Map.put(params, :customers, customers)
    locations = Location.get_locations(%{locations: [params.location_id]})
    first_location = Enum.at(locations, 0)
    params = Map.put(params, :timezone, first_location.timezone.id)

    struct
    |> cast(
      params,
      ~w(business_id message send_now send_date send_time is_active timezone deal_id survey_id location_id)a
    )
    |> put_assoc(:groups, MemberGroup.get_membergroups(params))
    |> put_assoc(:categories, Category.get_categories(params))
    |> put_assoc(:customers, Customer.get_customers(params))
    |> put_assoc(:products, Product.get_products(params))
    |> validate_required(~w(business_id message send_now send_date location_id)a)
  end

  defp filter(query, %{options: %{filters: filters}}) do
    sent_filter = find_filter(filters, "sent")

    query
    |> filter_sent(sent_filter)
  end

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_sent(query, nil), do: query

  defp filter_sent(query, %{args: args, field: _}) do
    sent = Enum.at(args, 0)
    direction = if sent == "false", do: :asc, else: :desc

    from(c in query,
      where: c.sent == ^Enum.at(args, 0),
      order_by: [{^direction, c.send_date}, {^direction, c.send_time}]
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

  defp insert(struct) do
    %Campaign{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def sent(id) do
    Campaign
    |> Repo.get(id)
    |> change(%{sent: true})
    |> Repo.update()
  end

  def scheduled(id) do
    Campaign
    |> Repo.get(id)
    |> change(%{schedueld: true})
    |> Repo.update()
  end

  def cancel(business_id, id) do
    case get_by_business_id(business_id, id) do
      {:error, error} ->
        {:error, error}

      {:ok, campaign} ->
        campaign
        |> change(%{is_active: false})
        |> Repo.update()
    end
  end

  # @TODO - test to ensure update makes sense here
  # Should only be able to update an unsent campaign
  # and if this is the case, do we preload all the things again
  # when we should be grabbing these things from the client anyhow?
  defp update(struct) do
    Campaign
    |> Repo.get(struct.id)
    |> Repo.preload(:location)
    |> Repo.preload(:groups)
    |> Repo.preload(:categories)
    |> Repo.preload(:products)
    |> Repo.preload(:customers)
    |> Repo.preload(:deal)
    |> changeset(struct)
    |> Repo.update()
  end

  def update_customers(params) do
    customers = Map.get(params, :customers, [])
    customers = Enum.map(customers, fn c -> c.id end)
    struct = %{customers: customers}

    Campaign
    |> Repo.get(params.id)
    |> Repo.preload(:customers)
    |> customer_changeset(struct)
    |> Repo.update()
  end

  defp customer_changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(business_id message send_now send_date send_time is_active deal_id survey_id location_id)a
    )
    |> put_assoc(:customers, Customer.get_customers(params))
  end
end
