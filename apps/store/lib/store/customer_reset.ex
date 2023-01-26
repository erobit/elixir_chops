defmodule Store.CustomerReset do
  use Store.Model

  schema "customer_resets" do
    field(:code, :string)
    field(:phone, :string)
    field(:email, :string)
    field(:expires, ConvertUTCDateTime)
    field(:sent, :boolean)
    field(:received, :boolean)
    field(:used, :boolean)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def delete_expired() do
    from(r in CustomerReset,
      where: r.expires < ^DateTime.utc_now()
    )
    |> Repo.delete_all()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(code phone email expires sent received used)a)
    |> validate_required(~w(code expires sent received used)a)
    |> unique_constraint(:code, name: "customer_resets_code_index")
  end

  def get_by_code(code) do
    from(r in CustomerReset,
      where: r.code == ^code and r.expires > ^DateTime.utc_now() and r.used == false,
      order_by: [desc: r.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  def sent(id) do
    update(%{id: id, sent: true})
  end

  def received(id) do
    update(%{id: id, received: true})
  end

  def used(id) do
    delete(id)
  end

  defp insert(struct) do
    %CustomerReset{}
    |> put_expiry_date()
    |> changeset(struct)
    |> Repo.insert()
  end

  defp delete(id) do
    CustomerReset
    |> Repo.get!(id)
    |> Repo.delete()
  end

  defp update(struct) do
    CustomerReset
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp put_expiry_date(struct) do
    struct
    |> Map.put(:expires, Timex.shift(DateTime.utc_now(), days: 7))
  end
end
