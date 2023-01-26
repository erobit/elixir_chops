defmodule Store.Repo.Migrations.ChangeTableAdminEmployeesAddPasswordFields do
  use Ecto.Migration

  def change do
    alter table(:admin_employees) do
      add(:password_hash, :string)
    end
  end
end
