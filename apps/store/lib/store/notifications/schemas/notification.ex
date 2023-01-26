defmodule Store.Notify.Notification do
  use Store.Model

  @employee_notification_types ~w(
    customer_joined_shop
    referral_sent
    new_review
    updated_review
  )

  @manager_notification_types @employee_notification_types ++ ~w(

  )

  # @owner_notification_types @manager_notification_types ++ ~w(
  #   employee_created
  #   employee_disabled
  #   employee_changed
  # )
  @owner_notification_types @manager_notification_types ++ ~w(
  )

  @notification_types @owner_notification_types

  schema "notifications" do
    field(:metadata, :map)
    field(:type, :string)
    field(:is_read, :boolean, default: false)
    field(:is_deleted, :boolean, default: false)
    belongs_to(:employee, Employee)
    belongs_to(:location, Location)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def get_employee_notifications(employee_id, options) do
    employee_notifications_query(employee_id)
    |> preload(:location)
    |> paginate(options)
  end

  def count_unread_notifications(employee_id) do
    count =
      employee_notifications_query(employee_id)
      |> by_unread()
      |> Repo.aggregate(:count, :id)

    {:ok, %{id: 1, count: count}}
  end

  defp employee_notifications_query(employee_id) do
    from(n in Notification,
      where:
        n.employee_id == ^employee_id and not n.is_deleted and
          n.type not in fragment(
            "SELECT type FROM employee_notification_preferences enp WHERE enp.employee_id = ?",
            ^employee_id
          ),
      order_by: [desc: n.inserted_at]
    )
  end

  defp by_unread(query) do
    from(n in query, where: not n.is_read)
  end

  def get_notification_preferences(employee_id, role) do
    notification_types =
      case role do
        "superadmin" -> @owner_notification_types
        "owner" -> @owner_notification_types
        "manager" -> @manager_notification_types
      end

    preferences =
      from(enp in "employee_notification_preferences",
        where: enp.employee_id == ^employee_id,
        select: %{
          id: enp.id,
          type: enp.type
        }
      )
      |> Repo.all()

    {:ok,
     Enum.map(notification_types, fn type ->
       preference =
         Enum.find(preferences, fn p ->
           p.type == type
         end)

       %{id: type, disabled: not is_nil(preference)}
     end)}
  end

  def mark_all_as_read(employee_id) do
    from(n in Notification,
      where: n.employee_id == ^employee_id
    )
    |> Repo.update_all(set: [is_read: true])

    {:ok, %{success: true}}
  end

  def notify(employees, notification) do
    notifications =
      filter_employees_for_type(employees, notification.type)
      |> Enum.map(fn e ->
        time = DateTime.truncate(DateTime.utc_now(), :second)

        Map.merge(notification, %{
          employee_id: e.id,
          inserted_at: time,
          updated_at: time
        })
      end)

    Repo.insert_all(Notification, notifications)
  end

  def filter_employees_for_type(employees, type) do
    Enum.filter(employees, fn e ->
      types =
        cond do
          e.role == "owner" -> @owner_notification_types
          e.role == "manager" -> @manager_notification_types
        end

      Enum.member?(types, type)
    end)
  end

  def save_preference(type, disabled, employee_id) do
    case disabled do
      true -> disable_preference(type, employee_id)
      false -> enable_preference(type, employee_id)
    end

    {:ok, %{id: type, disabled: disabled}}
  end

  defp disable_preference(type, employee_id) do
    Ecto.Adapters.SQL.query!(
      Store.Repo,
      "INSERT INTO employee_notification_preferences (employee_id, type) VALUES ($1, $2)",
      [employee_id, type]
    )
  end

  defp enable_preference(type, employee_id) do
    Ecto.Adapters.SQL.query!(
      Store.Repo,
      "DELETE FROM employee_notification_preferences WHERE employee_id=$1 AND type=$2",
      [employee_id, type]
    )
  end

  defp paginate(query, %{page: %{offset: offset, limit: limit}}) do
    results =
      query
      |> Repo.paginate(page: offset, page_size: limit)

    {:ok, results}
  end

  defp insert(struct) do
    %Notification{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Notification
    |> Repo.get(struct.id)
    |> changeset(struct)
    |> Repo.update()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, ~w(type is_read is_deleted employee_id)a)
    |> validate_required(~w(employee_id type)a)
    |> validate_inclusion(:type, @notification_types)
  end
end
