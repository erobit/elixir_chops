defmodule Store.Repo.Migrations.CreateTableCustomerNotify do
  use Ecto.Migration

  def change do
    create table(:customer_notifications) do
      add(:sent, :boolean, null: false, default: false)
      add(:customer_id, references(:customers), null: false)
      timestamps(type: :timestamptz)
    end

    flush()

    # Add a field `point` with type `geometry(Point,4326)`.
    # This will store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
    execute("SELECT AddGeometryColumn('customer_notifications', 'point', 4326, 'POINT', 2)")
    execute("CREATE INDEX customer_notify on locations USING gist(point)")
  end
end
