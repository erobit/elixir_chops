defmodule Store.Messaging.SMSSetting do
  use Store.Model

  schema "sms_settings" do
    field(:provider, :string)
    field(:phone_number, :string)
    field(:max_sms, :integer)
    field(:send_distributed, :boolean, default: false)
    field(:distributed_uuid, :string)
    belongs_to(:location, Store.Location)
    timestamps(type: :utc_datetime)
  end

  def get(id) do
    SMSSetting
    |> Repo.get(id)
  end

  def get_by_location(id) do
    SMSSetting
    |> Repo.get_by(location_id: id)
  end

  def get_by_phone(phone) do
    from(s in SMSSetting,
      where: s.phone_number == ^phone,
      order_by: [desc: s.id]
    )
    |> Repo.all()
  end

  def get_all_phone_numbers(provider) do
    from(s in SMSSetting,
      where: s.provider == ^provider,
      distinct: s.phone_number,
      select: s.phone_number
    )
    |> Repo.all()
  end

  def in_use?(phone, business_id) do
    from(s in SMSSetting,
      join: l in assoc(s, :location),
      where: s.phone_number == ^phone and l.business_id != ^business_id,
      distinct: s.phone_number,
      select: s.phone_number
    )
    |> Repo.exists?()
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  defp insert(struct) do
    %SMSSetting{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    SMSSetting
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      ~w(location_id provider phone_number max_sms send_distributed distributed_uuid)a
    )
    |> validate_required(~w(location_id provider max_sms send_distributed)a)
  end
end
