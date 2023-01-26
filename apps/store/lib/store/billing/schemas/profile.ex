defmodule Billing.Schemas.Profile do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Store.Repo
  alias Billing.Schemas.{Profile, Package}

  schema "billing_profiles" do
    belongs_to(:location, Store.Location)
    # required to add cards
    field(:profile_id, :string)
    field(:locale, :string)
    field(:payment_token, :string)
    # extra
    field(:first_name, :string)
    field(:middle_name, :string)
    field(:last_name, :string)
    field(:birth_date, :date)
    field(:email, :string)
    field(:phone, :string)
    field(:ip, :string)
    field(:gender, :string)
    field(:nationality, :string)
    field(:cell_phone, :string)
    # domain specific
    field(:payment_type, :string)
    field(:billing_start, :date)
    field(:billing_amount, :decimal)
    field(:billing_credit, :decimal)
    belongs_to(:package, Package)
    timestamps(type: :utc_datetime)
  end

  def get_active_credit_profiles() do
    from(p in Profile,
      join: pkg in assoc(p, :package),
      join: l in assoc(p, :location),
      join: b in assoc(l, :business),
      preload: [location: {l, business: b}, package: pkg],
      where:
        b.type == "dispensary" and l.is_active and b.is_active and p.payment_type == "credit_card" and
          (is_nil(p.billing_start) or fragment("? <= now()", p.billing_start))
    )
    |> Repo.all()
  end

  def get_trial_periods(business_id) do
    from(p in Profile,
      join: l in assoc(p, :location),
      join: b in assoc(l, :business),
      where:
        b.is_active and l.is_active and b.id == ^business_id and
          fragment(
            "? >= DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || ''))",
            p.billing_start,
            l.timezone
          ),
      select: %{
        days_left:
          fragment(
            "DATE_PART('day', ? - DATE_TRUNC('day', now() AT TIME ZONE (?->>'id' || '')))",
            p.billing_start,
            l.timezone
          ),
        name: l.name,
        location_id: p.location_id,
        billing_start: p.billing_start
      }
    )
    |> Repo.all()
  end

  def get_with_preloads(profile_id) do
    from(p in Profile,
      join: l in assoc(p, :location),
      join: b in assoc(l, :business),
      preload: [
        location: {l, business: b}
      ],
      where: p.id == ^profile_id
    )
    |> Repo.one()
  end

  def get_by_location_id(location_id) do
    Profile
    |> Repo.get_by(location_id: location_id)
  end

  def link(location_id, profile_id) do
    get_by_location_id(location_id)
    |> change(%{profile_id: profile_id})
    |> Repo.update()
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  defp insert(struct) do
    %Profile{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Profile
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  def update_billing_credit(id, balance) do
    Profile
    |> Repo.get(id)
    |> change(%{billing_credit: balance})
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(location_id profile_id locale payment_type payment_token 
      billing_start package_id billing_amount billing_credit)a
    )
    |> validate_required(~w(location_id)a)
    |> foreign_key_constraint(:location_id)
    |> foreign_key_constraint(:profile_id)
  end
end
