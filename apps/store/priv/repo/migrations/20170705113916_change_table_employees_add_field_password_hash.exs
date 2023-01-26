defmodule Store.Repo.Migrations.ChangeTableEmployeesAddFieldPasswordHash do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      add(:password_hash, :string)
    end
  end
end
