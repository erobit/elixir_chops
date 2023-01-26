defmodule Store.Repo.Migrations.CreateTableAdminEmployeeResets do
  use Ecto.Migration

  def change do
    create table(:admin_employee_resets, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :string, null: false)
      add(:expires, :timestamptz, null: false)
      add(:sent, :boolean, null: false, default: false)
      add(:used, :boolean, null: false, default: false)
      add(:ip_requestor, :string)
      add(:ip_resettor, :string)
      add(:employee_id, references(:admin_employees), null: false)
      timestamps(type: :timestamptz)
    end
  end
end
