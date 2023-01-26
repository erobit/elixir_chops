defmodule Store.Inventory.Integration.ProductIntegration do
  use Store.Model

  schema "product_integrations" do
    field(:name, :string, null: false)
    field(:api_key, :string, null: false)
    field(:client_id, :integer)
    field(:ext_location_id, :integer)
    field(:is_active, :boolean)
    belongs_to(:location, Store.Location)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def get(id) do
    ProductIntegration
    |> Repo.get(id)
  end

  def get_by_location(location_id) do
    query =
      from(p in ProductIntegration,
        where: p.location_id == ^location_id and p.is_active
      )

    case Repo.one(query) do
      nil -> {:error, nil}
      integration -> {:ok, integration}
    end
  end

  def toggle_active(id) do
    integration =
      from(p in ProductIntegration,
        where: p.id == ^id
      )
      |> Repo.one()

    change(integration, %{is_active: not integration.is_active})
    |> Repo.update()
  end

  def delete_by_location(location_id) do
    case Repo.get_by(ProductIntegration, location_id: location_id) do
      nil -> {:ok, %{}}
      integration -> Repo.delete(integration)
    end
  end

  defp insert(struct) do
    %ProductIntegration{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    ProductIntegration
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(location_id name api_key client_id ext_location_id is_active)a
    )
    |> validate_required(~w(location_id name api_key is_active)a)
    |> foreign_key_constraint(:location_id)
  end
end
