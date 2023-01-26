defmodule Store.Loyalty.Reward do
  use Store.Model

  @reward_types ~w(loyalty first_time birthday referral facebook review)
  def reward_types, do: @reward_types

  schema "rewards" do
    field(:name, :string)
    field(:type, :string)
    field(:points, :integer)
    field(:is_active, :boolean)
    belongs_to(:business, Store.Business)
    belongs_to(:location, Store.Location)

    many_to_many(:categories, Store.Inventory.Category,
      join_through: "rewards_categories",
      on_replace: :delete
    )

    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    case Map.get(struct, :id) do
      nil -> insert(struct)
      _ -> update(struct)
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(business_id location_id name type points is_active)a)
    |> put_assoc(:categories, Category.get_categories(params))
    |> validate_required(~w(business_id location_id name type points is_active)a)
    |> unique_constraint(:type)
    |> validate_inclusion(:type, @reward_types)
  end

  def get_active_reward(id) do
    case Repo.get_by(Reward, id: id, is_active: true) do
      nil -> {:error, "Reward is not active"}
      reward -> {:ok, reward}
    end
  end

  def get_by_locations_categories_and_type(location_ids, category_ids, type) do
    from(r in Reward,
      join: c in assoc(r, :categories),
      distinct: r.id,
      where:
        r.location_id in ^location_ids and r.type == ^type and r.is_active == true and
          c.id in ^category_ids
    )
    |> preload(:location)
    |> preload(:categories)
    |> Repo.all()
  end

  def get_by_location_and_type(location_id, type) do
    from(r in Reward,
      where: r.location_id == ^location_id and r.type == ^type and r.is_active == true
    )
    |> preload(:categories)
    |> Repo.one()
  end

  def get_by_location(location_id, type) do
    query =
      from(r in Reward,
        where: r.location_id == ^location_id and r.is_active == true and r.type == ^type
      )

    case Repo.one(query) do
      nil -> {:error, "Could not find active loyalty reward for location"}
      reward -> {:ok, reward}
    end
  end

  def get_all(business_id, location_ids) do
    Reward
    |> preload(:categories)
    |> where([r], r.business_id == ^business_id and r.location_id in ^location_ids)
    |> order_by([d], d.type)
    |> Repo.all()
  end

  def toggle_active(id, is_active) do
    Reward
    |> Repo.get(id)
    |> change(%{is_active: is_active})
    |> Repo.update()
  end

  defp insert(struct) do
    %Reward{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp update(struct) do
    Reward
    |> Repo.get(struct.id)
    |> Repo.preload(:categories)
    |> changeset(struct)
    |> Repo.update()
  end
end
