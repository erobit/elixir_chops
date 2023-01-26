defmodule Store.CustomerImport do
  use Store.Model

  schema "customer_imports" do
    belongs_to(:location, Location)
    field(:send_sms, :boolean)
    field(:message, :string)
    field(:customers, {:array, :string})
    field(:confirmation, :boolean)
    belongs_to(:employee, Store.Employee)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    %CustomerImport{}
    |> changeset(struct)
    |> Repo.insert()
  end

  def get(id) do
    CustomerImport
    |> Repo.get(id)
  end

  @doc """
  Builds a changeset based on 'struct' and 'params'
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(location_id employee_id confirmation send_sms message customers)a)
    |> validate_required(~w(location_id send_sms customers)a)
  end
end
