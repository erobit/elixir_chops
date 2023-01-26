defmodule Billing.Schemas.Package do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Store.Repo
  alias Billing.Schemas.{Package}

  schema "billing_packages" do
    field(:amount, :decimal)
    field(:description, :string)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  defp insert(struct) do
    %Package{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Package
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(
      params,
      ~w(amount description)a
    )
    |> validate_required(~w(amount)a)
  end
end
