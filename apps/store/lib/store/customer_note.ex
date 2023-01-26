defmodule Store.CustomerNote do
  use Store.Model
  alias Store.CustomerNoteMetadata

  @note_types ~w(note add_point remove_point redeemed_reward redeemed_deal)

  schema "customer_notes" do
    field(:body, :string)
    field(:flagged, :boolean)
    field(:type, :string, default: "note")
    embeds_one(:metadata, CustomerNoteMetadata, on_replace: :delete)
    belongs_to(:employee, Store.Employee)
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)

    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def log_reward_redeemed(customer_id, location_id, employee_id, reward, type) do
    create(%{
      customer_id: customer_id,
      location_id: location_id,
      employee_id: employee_id,
      type: "redeemed_#{type}",
      metadata: %{reward_name: reward.name, reward_id: reward.id}
    })
  end

  def log_add_point(customer_id, location_id, employee_id) do
    case get_todays_note(customer_id, location_id, employee_id, "add_point") do
      nil ->
        create(%{
          customer_id: customer_id,
          location_id: location_id,
          employee_id: employee_id,
          type: "add_point",
          metadata: %{count: 1}
        })

      note ->
        note
        |> change(%{metadata: %{count: note.metadata.count + 1}})
        |> Repo.update()
    end
  end

  def log_remove_point(customer_id, location_id, employee_id) do
    case get_todays_note(customer_id, location_id, employee_id, "remove_point") do
      nil ->
        create(%{
          customer_id: customer_id,
          location_id: location_id,
          employee_id: employee_id,
          type: "remove_point",
          metadata: %{count: 1}
        })

      note ->
        note
        |> change(%{metadata: %{count: note.metadata.count + 1}})
        |> Repo.update()
    end
  end

  defp get_todays_note(customer_id, location_id, employee_id, type) do
    from(cn in CustomerNote,
      where:
        cn.customer_id == ^customer_id and cn.location_id == ^location_id and cn.type == ^type and
          cn.employee_id == ^employee_id and
          fragment("DATE_TRUNC('day', now()) = DATE_TRUNC('day', ?)", cn.inserted_at)
    )
    |> Repo.one()
  end

  def get_all(customer_id, location_id, inverted) do
    direction =
      case inverted do
        true -> :desc
        false -> :asc
      end

    from(n in CustomerNote,
      join: e in assoc(n, :employee),
      where: n.customer_id == ^customer_id and n.location_id == ^location_id,
      preload: [employee: e],
      order_by: [{^direction, n.flagged}, {^direction, n.inserted_at}]
    )
    |> Repo.all()
  end

  defp insert(struct) do
    %CustomerNote{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    CustomerNote
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, ~w(body flagged employee_id customer_id location_id type)a)
    |> validate_required(~w(employee_id customer_id location_id)a)
    |> put_embed(:metadata, parse_metadata(struct, params))
    |> validate_inclusion(:type, @note_types)
    |> foreign_key_constraint(:employee_id)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:business_id)
  end

  defp parse_metadata(struct, params) do
    data = Map.get(params, :metadata)

    if is_nil(data) do
      struct.metadata
    else
      CustomerNoteMetadata.create(data)
    end
  end
end
