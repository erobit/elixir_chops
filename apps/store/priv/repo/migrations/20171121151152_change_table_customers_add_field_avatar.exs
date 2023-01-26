defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldAvatar do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:avatar, :string, null: true)
    end
  end
end
