defmodule Store.Repo.Migrations.ChangeTableMembershipLocationsAddFieldNotificationsEnabled do
  use Ecto.Migration

  def change do
    alter table(:membership_locations) do
      add(:notifications_enabled, :boolean, default: true)
    end
  end
end
