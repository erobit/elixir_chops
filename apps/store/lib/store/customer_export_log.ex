defmodule Store.CustomerExportLog do
  use Store.Model

  schema "customer_export_logs" do
    field(:ip_address, :string, null: false)
    field(:type, :string, null: false)
    belongs_to(:employee, Employee)
    timestamps(type: :utc_datetime)
  end

  def create(struct) do
    insert(struct)
  end

  defp insert(struct) do
    %CustomerExportLog{}
    |> changeset(struct)
    |> Repo.insert()
  end

  defp changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(ip_address type employee_id)a)
    |> validate_required(~w(ip_address type employee_id)a)
  end
end
