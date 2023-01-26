defmodule Store.Repo.Migrations.AlterTableCustomersAddBirthdateVerified do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:birthdate_verified, :boolean, default: false)
    end
  end
end
