defmodule Store.Repo.Migrations.UpdateTableEmployeesAddSoftDelete do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add(:is_deleted, :boolean, default: false)
    end
  end
end
