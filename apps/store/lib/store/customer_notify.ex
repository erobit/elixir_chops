defmodule Store.CustomerNotify do
  use Store.Model

  schema "customer_notifications" do
    field(:point, Geo.PostGIS.Geometry)
    field(:sent, :boolean, default: false)
    belongs_to(:customer, Customer)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
    end
  end

  defp insert(struct) do
    %CustomerNotify{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(customer_id point sent)a)
    |> validate_required(~w(customer_id sent)a)
    |> foreign_key_constraint(:customer_id)
  end
end
