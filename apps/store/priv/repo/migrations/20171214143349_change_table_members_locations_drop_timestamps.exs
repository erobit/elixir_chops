defmodule Store.Repo.Migrations.ChangeTableMembersLocationsDropTimestamps do
  use Ecto.Migration

  def up do
    alter table(:members_locations) do
      remove(:inserted_at)
      remove(:updated_at)
    end
  end

  def down do
    alter table(:members_locations) do
      timestamps(type: :timestamptz)
    end
  end
end
