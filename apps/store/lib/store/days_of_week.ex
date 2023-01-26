defmodule Store.DaysOfWeek do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:weekday, :string, []}
  embedded_schema do
    field(:active, :boolean)
  end

  def create(struct) do
    %Store.DaysOfWeek{}
    |> changeset(struct)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:weekday, :active])
    |> validate_required([:weekday, :active])
  end
end
