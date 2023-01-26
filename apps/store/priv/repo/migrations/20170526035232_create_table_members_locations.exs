defmodule Store.Repo.Migrations.CreateTableMembersLocations do
  use Ecto.Migration

  def change do
    create table(:members_locations, primary_key: false) do
      add(:member_id, references(:members), null: false)
      add(:location_id, references(:locations), null: false)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:members_locations, [:member_id, :location_id]))
  end
end
