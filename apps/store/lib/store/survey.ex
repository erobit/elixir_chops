defmodule Store.Survey do
  use Store.Model

  @salt "1f4ny0n3c0uldgu355th1sth3y4r3g0d"

  schema "surveys" do
    field(:name, :string)
    field(:content, :string)
    field(:is_active, :boolean, null: false, default: true)
    field(:submissions, :integer, virtual: true, default: 0)
    belongs_to(:business, Business)
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
    from(s in Survey,
      where: s.id == ^id and s.business_id == ^business_id
    )
    |> Repo.one()
  end

  def paginate(business_id, location_id, %{options: options}) do
    Survey
    |> where([s], s.business_id == ^business_id and s.location_id == ^location_id)
    |> sort(options)
    |> select([:id, :name, :is_active, :inserted_at])
    |> Repo.paginate(page: options.page.offset, page_size: options.page.limit)
  end

  def generate_url(subdomain, customer_id, location_id, survey_id, campaign_id) do
    config = Application.get_env(:store, Store.Surveyor)
    prefix = config[:prefix]
    path = config[:path]
    cypher = generate_hash(customer_id, location_id, survey_id, campaign_id)
    "#{prefix}#{subdomain}.#{path}#{cypher}"
  end

  def decode_hash(hash) do
    Hashids.decode(salt(), hash)
  end

  ####################
  # Private Functions
  ####################

  defp generate_hash(customer_id, location_id, survey_id, campaign_id) do
    Hashids.encode(salt(), [customer_id, location_id, survey_id, campaign_id])
  end

  defp salt() do
    Hashids.new(
      # using a custom salt helps producing unique cipher text
      salt: @salt,
      # minimum length of the cipher text (1 by default)
      min_len: 4
    )
  end

  defp sort(query, %{sort: %{field: fieldname, order: order}}) do
    direction = if order == 1, do: :asc, else: :desc

    query
    |> order_by([s], [{^direction, field(s, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _) do
    query
    |> order_by(desc: :inserted_at)
  end

  defp insert(struct) do
    %Survey{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Survey
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, ~w(name content is_active business_id location_id)a)
    |> validate_required(~w(name content business_id location_id)a)
    |> foreign_key_constraint(:business_id)
  end
end
