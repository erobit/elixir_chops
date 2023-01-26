defmodule Store.Repo.Migrations.ChangeTableCustomersModifyFieldLocationEnabledStatusToNotificationsEnabled do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      remove(:location_enabled_status)
      add(:notifications_enabled, :boolean, default: true)
    end
  end
end
