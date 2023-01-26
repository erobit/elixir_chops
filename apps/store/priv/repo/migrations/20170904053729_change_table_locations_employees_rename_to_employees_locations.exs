defmodule Store.Repo.Migrations.ChangeTableLocationsEmployeesRenameToEmployeesLocations do
  use Ecto.Migration

  def change do
    rename(table(:locations_employees), to: table(:employees_locations))
  end
end
