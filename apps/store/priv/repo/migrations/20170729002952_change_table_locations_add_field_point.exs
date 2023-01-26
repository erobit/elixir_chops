defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldPoint do
  use Ecto.Migration

  def up do
    # Add a field `point` with type `geometry(Point,4326)`.
    # This will store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
    execute("SELECT AddGeometryColumn('locations', 'point', 4326, 'POINT', 2)")
    execute("CREATE INDEX locations_point_index on locations USING gist(point)")
  end

  def down do
    alter table(:locations) do
      remove(:point)
    end

    execute("DROP INDEX locations_point_index")
  end
end
