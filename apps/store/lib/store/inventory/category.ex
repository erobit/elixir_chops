defmodule Store.Inventory.Category do
  use Store.Model

  schema "categories" do
    field(:name, :string)
    many_to_many(:deals, Store.Loyalty.Deal, join_through: "deals_categories")
    many_to_many(:rewards, Store.Loyalty.Reward, join_through: "rewards_categories")
    many_to_many(:customers, Store.Customer, join_through: "customers_categories")
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %Category{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(id name)a)
    |> validate_required(~w(name)a)
  end

  def get(id) do
    Category
    |> Repo.get(id)
  end

  def get_by_name(name) do
    from(c in Category,
      where: c.name == ^name,
      limit: 1
    )
    |> Repo.one()
  end

  def get_customer_favourites(customer_id) do
    from(cat in Category,
      join: cust in assoc(cat, :customers),
      where: cust.id == ^customer_id
    )
    |> Repo.all()
    |> Enum.map(fn r -> r.id end)
  end

  def get_categories(struct) do
    Map.get(struct, :categories, [])
    |> Category.get_by_ids()
  end

  def get_categories(struct, params) do
    case Map.get(params, :categories, nil) do
      nil -> struct.categories
      categories -> categories |> Category.get_by_ids()
    end
  end

  def get_by_ids(ids) do
    Repo.all(from(c in Category, where: c.id in ^ids))
  end

  def get_all() do
    Category
    |> Repo.all()
  end
end
