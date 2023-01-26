defmodule Store.Inventory.PricingPreference do
  use Store.Model

  schema "pricing_preferences" do
    field(:is_basic, :boolean, default: false)
    belongs_to(:location, Store.Location)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def get_by_location_id(location_id) do
    PricingPreference
    |> where([pp], pp.location_id == ^location_id)
    |> Repo.one()
  end

  def get_all() do
    PricingPreference
    |> Repo.all()
  end

  def get_or_create(location_id) do
    case get_by_location_id(location_id) do
      nil ->
        case create(%{location_id: location_id, is_basic: false}) do
          {:ok, preference} -> preference
          err -> err
        end

      preference ->
        preference
    end
  end

  def toggle_business_preference(location_id, is_basic) do
    preference = get_by_location_id(location_id)

    case preference do
      nil -> create(%{is_basic: is_basic, location_id: location_id})
      pref -> create(%{id: pref.id, is_basic: is_basic})
    end
  end

  def insert(struct) do
    %PricingPreference{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def update(struct) do
    PricingPreference
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, ~w(is_basic location_id)a)
    |> validate_required(~w(location_id)a)
    |> foreign_key_constraint(:location_id)
  end
end
