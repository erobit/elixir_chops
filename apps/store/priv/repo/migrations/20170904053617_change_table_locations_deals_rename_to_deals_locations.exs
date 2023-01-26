defmodule Store.Repo.Migrations.ChangeTableLocationsDealsRenameToDealsLocations do
  use Ecto.Migration

  def change do
    rename(table(:locations_deals), to: table(:deals_locations))
  end
end
