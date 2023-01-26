defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldPolygon do
  use Ecto.Migration

  def up do
    execute("SELECT AddGeometryColumn('locations', 'polygon', 900913, 'POLYGON', 2)")
    execute("CREATE INDEX locations_polygon_index on locations USING gist(polygon)")
  end

  def down do
    alter table(:locations) do
      remove(:polygon)
    end

    execute("DROP INDEX locations_polygon_index")
  end
end
