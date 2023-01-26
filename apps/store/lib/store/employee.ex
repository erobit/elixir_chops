defmodule Store.Employee do
  use Store.Model
  require Ecto.Query.API

  @employee_roles ~w(superadmin owner manager budtender)
  @visible_roles ~w(owner manager budtender)

  schema "employees" do
    field(:email, :string)
    field(:phone, :string)
    field(:role, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:is_active, :boolean)
    field(:is_deleted, :boolean, default: false)
    belongs_to(:business, Store.Business)

    many_to_many(:locations, Store.Location,
      join_through: "employees_locations",
      on_replace: :delete,
      on_delete: :delete_all
    )

    has_many(:all_locations, Store.Location,
      foreign_key: :business_id,
      references: :business_id
    )

    has_one(:customer, Store.Customer,
      foreign_key: :phone,
      references: :phone
    )

    has_many(:employee_resets, Store.EmployeeReset, on_delete: :delete_all)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def toggle_active(id, is_active) do
    changes =
      Employee
      |> Repo.get(id)
      |> change(%{is_active: is_active})

    case fetch_field(changes, :role) do
      {:data, "owner"} ->
        {:data, business_id} = fetch_field(changes, :business_id)

        other_owners =
          from(e in Employee,
            where:
              e.role == "owner" and e.is_active and not e.is_deleted and
                e.business_id == ^business_id and e.id != ^id
          )
          |> Repo.all()

        case length(other_owners) do
          0 -> {:error, "must_have_atleast_one_owner"}
          _ -> Repo.update(changes)
        end

      _ ->
        Repo.update(changes)
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(business_id phone email role is_active is_deleted password)a)
    |> put_assoc(:locations, Location.get_locations(params))
    |> validate_required(~w(business_id phone email role is_active is_deleted)a)
    |> unique_constraint(:email, name: :employees_email_business_id_index)
    |> validate_inclusion(:role, @employee_roles)
    |> validate_length(:password, min: 4)
    # ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
    |> validate_format(:email, ~r/@/)
    |> foreign_key_constraint(:business_id)
    |> downcase_email()
  end

  def downcase_email(changeset) do
    update_change(changeset, :email, &String.downcase/1)
  end

  def authenticate(subdomain, email, password, repo \\ Repo) do
    employee =
      repo.one(
        from(employee in Employee,
          join: business in assoc(employee, :business),
          where:
            employee.email == ^String.downcase(email) and business.subdomain == ^subdomain and
              employee.is_active == true and business.is_active == true and
              employee.is_deleted == false,
          preload: [business: business]
        )
      )

    case check_password(employee, password) do
      true -> {:ok, sanitize(employee)}
      _ -> {:error, "Invalid login credentials"}
    end
  end

  def can_access_location?(employee_id, location_id) do
    query =
      from(e in Employee,
        join: b in assoc(e, :business),
        join: l in assoc(b, :locations),
        where:
          e.id == ^employee_id and e.is_active and e.is_deleted == false and b.is_active and
            l.id == ^location_id
      )

    case Repo.one(query) do
      nil -> {:ok, false}
      %Store.Employee{} -> {:ok, true}
    end
  end

  def get_by_roles(location_id, roles) do
    from(e in Employee,
      join: l in assoc(e, :locations),
      where: l.id == ^location_id and e.is_active and e.is_deleted == false and e.role in ^roles
    )
    |> Repo.all()
  end

  def get_owners(location_id) do
    from(e in Employee,
      join: l in assoc(e, :all_locations),
      where: l.id == ^location_id and e.is_active and e.is_deleted == false and e.role == "owner",
      distinct: e.id
    )
    |> Repo.all()
  end

  def get(id) do
    from(e in Employee,
      join: b in assoc(e, :business),
      left_join: l in assoc(e, :locations),
      left_join: al in assoc(e, :all_locations),
      where: b.is_active and e.is_active and not e.is_deleted,
      preload: [locations: l],
      preload: [all_locations: al],
      preload: [business: b]
    )
    |> Repo.get(id)
    |> set_locations()
    |> sanitize()
  end

  def me(id) do
    Employee
    |> select([:email, :phone, :role])
    |> Repo.get(id)
  end

  def get_email_by_id(id) do
    Employee
    |> select([:id, :email])
    |> Repo.get(id)
    |> Map.get(:email)
  end

  def soft_delete(employee) do
    Employee
    |> Repo.get(employee.id)
    |> change(%{is_deleted: true, is_active: false})
    |> Repo.update()
  end

  def get_by_email_and_business_id(email, business_id) do
    from(e in Employee,
      where:
        e.email == ^String.downcase(email) and e.business_id == ^business_id and
          e.is_active == true and e.is_deleted == false and e.role in ^@visible_roles
    )
    |> Repo.one()
  end

  def get_by_email_and_business_id_bypass_deleted(email, business_id) do
    from(e in Employee,
      where:
        e.email == ^String.downcase(email) and e.business_id == ^business_id and not e.is_active
    )
    |> preload(:locations)
    |> Repo.one()
  end

  def get_by_location_customer_id(customer_id, location_id) do
    from(e in Employee,
      join: b in assoc(e, :business),
      left_join: l in assoc(e, :locations),
      left_join: al in assoc(e, :all_locations),
      join: c in assoc(e, :customer),
      where:
        b.is_active and e.is_active and not e.is_deleted and al.id == ^location_id and
          c.id == ^customer_id,
      preload: [locations: l],
      preload: [all_locations: al],
      preload: [business: b]
    )
    |> Repo.all()
    |> Enum.at(0)
    |> set_locations()
    |> sanitize()
  end

  def set_password(business_id, email, password) do
    password_reset_changeset(business_id, email, password)
    |> Repo.update()
  end

  def password_reset_changeset(business_id, email, password) do
    get_by_email_and_business_id(email, business_id)
    |> change(%{password: password})
    |> put_password_hash()
  end

  def get_business_admin_by_location_id(location_id) do
    from(e in Employee,
      join: b in assoc(e, :business),
      join: l in assoc(b, :locations),
      where: e.role == "superadmin" and l.id == ^location_id,
      preload: [business: b]
    )
    |> Repo.one()
    |> sanitize
  end

  def get_business_admin(business_id) do
    from(e in Employee,
      join: b in assoc(e, :business),
      where: e.role == "superadmin" and e.business_id == ^business_id,
      preload: [business: b]
    )
    |> Repo.one()
    |> sanitize
  end

  def get_all_by_location(business_id, location_id) do
    from(e in Employee,
      left_join: l in assoc(e, :locations),
      left_join: b in assoc(l, :business),
      where:
        (l.id == ^location_id or e.role == "owner") and e.business_id == ^business_id and
          not e.is_deleted and e.is_active and e.role in ^@visible_roles,
      select: %{
        id: e.id,
        role: e.role
      }
    )
    |> Repo.all()
  end

  # @TODO: Sanitize / add security
  def get_all(business_id, location_ids, options) do
    from(e in Employee,
      left_join: l in assoc(e, :locations),
      left_join: c in assoc(e, :customer),
      where:
        e.business_id == ^business_id and e.is_deleted == false and e.role in ^@visible_roles and
          (l.id in ^location_ids or e.role == "owner"),
      preload: [locations: l, customer: c]
    )
    |> filter(options)
    |> search(options)
    |> sort(options)
    |> paginate(options)
  end

  defp insert(struct) do
    %Employee{}
    |> changeset(struct)
    |> put_password_hash()
    |> Repo.insert()
  end

  defp update(struct) do
    changes =
      Employee
      |> Repo.get(struct.id)
      |> Repo.preload(:locations)
      |> changeset(struct)

    case fetch_change(changes, :role) do
      # Role is Changing, lets validate there are other owners.
      {:ok, val} ->
        if val == "owner" do
          Repo.update(changes)
        else
          other_owners =
            from(e in Employee,
              where:
                e.role == "owner" and e.id != ^struct.id and e.is_active and not e.is_deleted and
                  e.business_id == ^struct.business_id
            )
            |> Repo.all()

          case length(other_owners) do
            0 -> {:error, "must_be_one_owner"}
            _ -> Repo.update(changes)
          end
        end

      # No Change to Role, proceed.
      :error ->
        Repo.update(changes)
    end
  end

  defp search(query, %{options: %{search: email}}) do
    query |> where([e], ilike(e.email, ^"%#{email}%"))
  end

  defp search(query, _options), do: query

  defp sort(query, %{options: %{sort: %{field: fieldname, order: order}}}) do
    direction = if order == 1, do: :asc, else: :desc
    query |> order_by([e], [{^direction, field(e, ^String.to_atom(fieldname))}])
  end

  defp sort(query, _options), do: query

  defp filter(query, %{options: %{filters: filters}}) do
    active_filter = find_filter(filters, "is_active")

    query
    |> filter_active(active_filter)
  end

  defp find_filter(filters, field) do
    Enum.find(filters, fn filter -> filter.field == field end)
  end

  defp filter_active(query, nil), do: query

  defp filter_active(query, %{args: args, field: _}) do
    case args do
      [] -> query
      ["true"] -> from(e in query, where: e.is_active == true)
      ["false"] -> from(e in query, where: e.is_active == false)
      _ -> query
    end
  end

  defp paginate(query, %{options: %{page: %{offset: offset, limit: limit}}}) do
    results = query |> Repo.paginate(page: offset, page_size: limit)
    {:ok, results}
  end

  defp paginate(queryset, _options) do
    queryset
    |> Repo.all()
  end

  # This is a private method used when authenticating and when serializing for
  # the jwt token during authentication to ensure only a limited and secure
  # fieldset is returned and stored within the jwt. We could expand this
  # to include locations and other relevant information in the future but it's
  # probably better to query it as it could change often.
  defp sanitize(nil), do: nil

  defp sanitize(employee) do
    employee
    |> Map.take([
      :__meta__,
      :__struct__,
      :id,
      :business_id,
      :business,
      :email,
      :role,
      :is_active,
      :locations
    ])
  end

  defp set_locations(nil), do: nil

  defp set_locations(employee) do
    case employee.role in ["superadmin", "owner"] do
      true -> Map.put(employee, :locations, employee.all_locations)
      false -> employee
    end
  end

  defp check_password(employee, password) do
    case employee do
      nil -> false
      _ -> Comeonin.Bcrypt.checkpw(password, employee.password_hash)
    end
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
