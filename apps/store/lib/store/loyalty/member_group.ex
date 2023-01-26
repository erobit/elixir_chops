defmodule Store.Loyalty.MemberGroup do
  use Store.Model

  schema "member_groups" do
    field(:name, :string)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %MemberGroup{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def get(id) do
    MemberGroup
    |> Repo.get(id)
  end

  def get_membergroups(struct) do
    Map.get(struct, :groups, [])
    |> MemberGroup.get_by_ids()
  end

  def get_by_ids(ids) do
    Repo.all(
      from(g in MemberGroup,
        where: g.id in ^ids,
        order_by: [asc: :id]
      )
    )
  end

  def get_all() do
    MemberGroup
    |> order_by(asc: :id)
    |> Repo.all()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(id name)a)
    |> validate_required(~w(name)a)
    |> unique_constraint(:name)
  end

  # @TODO
  # Create methods that return a list of the members that are within
  # each of the following groups.
  #
  # All customers
  # Loyal customers
  # Casual customers
  # Lapsed customers
  # One last mile
  # Hoarders
  # Big spenders
  # Top referrals
  # Birthday this month
  #
  # Optimization
  # -------------
  # Should this instead be generated nightly and stored in a join table
  # instead of everytime a message needs to be sent or the dashboard is loaded??
end
