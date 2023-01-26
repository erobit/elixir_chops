defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldPassword do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      add(:password_hash, :string)
    end
  end

  def down do
    alter table(:customers) do
      remove(:password_hash)
    end
  end
end
