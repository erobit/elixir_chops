defmodule Store.Repo.Migrations.CreateTableAdminEmployees do
  use Ecto.Migration

  def change do
    create table(:admin_employees) do
      add(:name, :string, null: false)
      add(:email, :string, null: false)
      add(:phone, :string)
      add(:role, :string, null: false)
      add(:is_active, :boolean, null: false)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:admin_employees, [:email], name: :admin_employees_email_index))
  end
end
