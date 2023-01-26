defmodule Store.Repo.Migrations.CreateTableLocationsEmployees do
  use Ecto.Migration

  def change do
    create table(:locations_employees, primary_key: false) do
      add(:employee_id, references(:employees), null: false)
      add(:location_id, references(:locations), null: false)
    end

    create(unique_index(:locations_employees, [:employee_id, :location_id]))
  end
end
