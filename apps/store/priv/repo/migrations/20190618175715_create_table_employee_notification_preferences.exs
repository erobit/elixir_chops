defmodule Store.Repo.Migrations.CreateTableEmployeeNotificationPreferences do
  use Ecto.Migration

  def change do
    create table(:employee_notification_preferences) do
      add(:employee_id, references(:employees), null: false)
      add(:type, :string, null: false)
    end

    create(unique_index(:employee_notification_preferences, [:employee_id, :type]))
  end
end
