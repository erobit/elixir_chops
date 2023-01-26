defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldEmailVerified do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:email_verified, :boolean, null: false, default: false)
    end
  end
end
