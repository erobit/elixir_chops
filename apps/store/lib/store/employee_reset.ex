defmodule Store.EmployeeReset do
  use Store.Model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "employee_resets" do
    field(:email, :string)
    field(:subdomain, :string)
    field(:expires, ConvertUTCDateTime)
    field(:sent, :boolean)
    field(:used, :boolean)
    field(:ip_requestor, :string)
    field(:ip_resettor, :string)
    belongs_to(:business, Store.Business)
    belongs_to(:employee, Store.Employee)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def delete_expired() do
    from(r in EmployeeReset,
      where: r.expires < ^DateTime.utc_now()
    )
    |> Repo.delete_all()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      ~w(id business_id employee_id subdomain email expires sent used ip_requestor ip_resettor)a
    )
    |> validate_required(~w(email business_id employee_id subdomain sent used)a)
  end

  def get(id) do
    from(r in EmployeeReset,
      where: r.id == ^id and r.expires > ^DateTime.utc_now() and r.used == false,
      order_by: [desc: r.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  def sent(id) do
    update(%{id: id, sent: true})
  end

  def used(id, ip_resettor) do
    update(%{id: id, used: true, ip_resettor: ip_resettor})
  end

  def used_changeset(id, ip_resettor) do
    get(id)
    |> changeset(%{id: id, used: true, ip_resettor: ip_resettor})
  end

  defp insert(struct) do
    %EmployeeReset{}
    |> put_expiry_date()
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    EmployeeReset
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp put_expiry_date(struct) do
    struct
    |> Map.put(:expires, Timex.shift(DateTime.utc_now(), days: 7))
  end
end
