defmodule Store.Repo.Migrations.ChangeTableVisitsAddFieldPoint do
  use Ecto.Migration

  def up do
    # Add a field `point` with type `geometry(Point,4326)`.
    # This will store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
    execute("SELECT AddGeometryColumn('visits', 'point', 4326, 'POINT', 2)")
    execute("CREATE INDEX visits_point_index on visits USING gist(point)")
  end

  def down do
    alter table(:visits) do
      remove(:point)
    end

    execute("DROP INDEX visits_point_index")
  end
end
