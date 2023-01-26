defmodule Store.Repo.Migrations.ChangeTableLocationsChangeFieldPolygon do
  use Ecto.Migration

  use Ecto.Migration

  def up do
    alter table(:locations) do
      remove(:polygon)
    end

    flush()

    execute("SELECT AddGeometryColumn('locations', 'polygon', 4326, 'POLYGON', 2)")
    execute("CREATE INDEX locations_polygon_index on locations USING gist(polygon)")
  end

  def down do
    alter table(:locations) do
      remove(:polygon)
    end

    execute("DROP INDEX locations_polygon_index")
  end
end
