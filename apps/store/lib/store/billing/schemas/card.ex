defmodule Billing.Schemas.Card do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Store.Repo
  alias Billing.Schemas.{Card, Profile}

  schema "billing_cards" do
    belongs_to(:profile, Profile)
    field(:card_id, :string)
    field(:payment_token, :string)
    field(:type, :string)
    field(:category, :string)
    field(:last_digits, :string)
    field(:expiry_month, :integer)
    field(:expiry_year, :integer)
    field(:status, :string)
    field(:is_default, :boolean)
    field(:nickname, :string)
    field(:holdername, :string)
    field(:bin, :string)
    field(:billing_address_id, :string)
    field(:is_deleted, :boolean)
    timestamps(type: :utc_datetime)
  end

  def get_by_location_id(location_id) do
    from(c in Card,
      join: p in assoc(c, :profile),
      where: p.location_id == ^location_id and c.is_deleted == false,
      order_by: [desc: c.is_default, desc: c.expiry_year, desc: c.expiry_month]
    )
    |> Repo.all()
  end

  def get_by_id(id) do
    Card
    |> preload(:profile)
    |> Repo.get(id)
  end

  def get_card_and_profile(id) do
    Card
    |> preload(:profile)
    |> Repo.get(id)
  end

  def get_all() do
    Card |> Repo.all()
  end

  def get_default(profile_id) do
    query =
      from(c in Card,
        join: p in assoc(c, :profile),
        where: p.id == ^profile_id and c.is_default and c.is_deleted == false,
        limit: 1
      )

    case Repo.one(query) do
      nil -> {:error, "no_default_card_assigned"}
      card -> {:ok, card}
    end
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def no_default_card?(profile_id) do
    from(c in Card,
      join: p in assoc(c, :profile),
      where: p.id == ^profile_id and c.is_deleted == false and c.is_default == true
    )
    |> Repo.exists?()
    |> Kernel.not()
  end

  def mark_deleted(id) do
    get_by_id(id)
    |> change(%{is_deleted: true})
    |> Repo.update()
  end

  def set_status(id, status) do
    get_by_id(id)
    |> change(%{status: status})
    |> Repo.update()
  end

  def clear_default(profile_id) do
    from(c in Card,
      join: p in assoc(c, :profile),
      where: p.id == ^profile_id and c.is_deleted == false
    )
    |> Repo.update_all(set: [is_default: false])
  end

  def set_default(id) do
    get_by_id(id)
    |> change(%{is_default: true})
    |> Repo.update()
  end

  def update_expiry(id, expiry_month, expiry_year) do
    get_by_id(id)
    |> change(%{expiry_month: expiry_month, expiry_year: expiry_year})
    |> Repo.update()
  end

  defp insert(struct) do
    %Card{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Card
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(profile_id card_id payment_token last_digits type category 
      expiry_month expiry_year status is_default nickname holdername 
      bin billing_address_id is_deleted)a
    )
    |> validate_required(~w(profile_id card_id payment_token type category
      last_digits expiry_month expiry_year status is_default)a)
  end
end
