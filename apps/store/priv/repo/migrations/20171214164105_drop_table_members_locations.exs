defmodule Store.Repo.Migrations.DropTableMembersLocations do
  use Ecto.Migration

  def change do
    drop(table(:members_locations))
  end
end
