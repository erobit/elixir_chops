defmodule Store.Loyalty.OptLog do
  use Store.Model

  @source_types ~w(join crm-toggle location-toggle global-toggle sms-stop sms-start)
  def source_types, do: @source_types

  schema "opt_log" do
    belongs_to(:customer, Store.Customer)
    belongs_to(:location, Store.Location)
    field(:opted_in, :boolean, null: false, default: true)
    field(:source, :string)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %OptLog{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(customer_id location_id opted_in source)a)
    |> validate_required(~w(customer_id location_id opted_in source)a)
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:location_id)
    |> validate_inclusion(:source, @source_types)
  end
end
