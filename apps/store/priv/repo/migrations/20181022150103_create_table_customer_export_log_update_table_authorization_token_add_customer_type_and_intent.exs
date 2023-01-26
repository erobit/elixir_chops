defmodule Store.Repo.Migrations.CreateTableCustomerExportLogUpdateTableAuthorizationTokenAddCustomerTypeAnd do
  use Ecto.Migration
  use Store.Model

  def change do
    create table(:customer_export_logs) do
      add(:employee_id, references(:employees), null: false)
      add(:ip_address, :string, null: false)
      add(:type, :string, null: false)
      timestamps(type: :timestamptz)
    end

    from(at in AuthorizationToken)
    |> Repo.delete_all()

    alter table(:authorization_tokens) do
      add(:intent, :string, null: false)
      add(:customer_export_type, :string)
      add(:expires, :timestamptz, null: false)
    end
  end
end
