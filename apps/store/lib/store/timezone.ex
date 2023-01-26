defmodule Store.Timezone do
  import Ecto.Changeset
  use Ecto.Schema

  embedded_schema do
    field(:name, :string)
    field(:dst_offset, :integer)
    field(:raw_offset, :integer)
  end

  def create(struct) do
    %Store.Timezone{}
    |> changeset(struct)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :name, :dst_offset, :raw_offset])
    |> validate_required([:id, :name, :dst_offset, :raw_offset])
  end
end
