defmodule Store.Repo.Migrations.CreateTableNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add(:metadata, :json)
      add(:type, :string)
      add(:employee_id, references(:employees), null: false)
      add(:location_id, references(:locations), null: false)
      add(:is_read, :boolean, default: false)
      add(:is_deleted, :boolean, default: false)
      timestamps(type: :timestamptz)
    end

    create(index(:notifications, [:employee_id, :type]))
  end
end
