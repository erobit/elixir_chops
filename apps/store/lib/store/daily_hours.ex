defmodule Store.DailyHours do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:weekday, :string, []}
  embedded_schema do
    field(:start, :string)
    field(:end, :string)
    field(:closed, :boolean)
  end

  def create(struct) do
    %Store.DailyHours{}
    |> changeset(struct)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:weekday, :start, :end, :closed])
    |> validate_required([:weekday, :start, :end, :closed])
  end
end
