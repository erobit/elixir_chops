defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldLocationEnabledStatus do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      add(:location_enabled_status, :integer, null: false, default: 0)
    end
  end

  def down do
    alter table(:customers) do
      remove(:location_enabled_status)
    end
  end
end
