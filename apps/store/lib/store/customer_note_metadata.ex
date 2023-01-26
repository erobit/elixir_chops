defmodule Store.CustomerNoteMetadata do
  use Store.Model

  @primary_key false
  embedded_schema do
    field(:count, :integer)
    field(:reward_name, :string)
    field(:reward_id, :integer)
    field(:reward_type, :string)
  end

  def create(struct) do
    %Store.CustomerNoteMetadata{}
    |> changeset(struct)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:count, :reward_name, :reward_id, :reward_type])
  end
end
