defmodule Store.Repo.Migrations.CreateTableMembershipLocations do
  use Ecto.Migration

  def change do
    create table(:membership_locations) do
      add(:membership_id, references(:memberships), null: false)
      add(:location_id, references(:locations), null: false)
      add(:is_active, :boolean, default: true)
      timestamps(type: :timestamptz)
    end

    create(
      unique_index(:membership_locations, [:membership_id, :location_id],
        name: :membership_locations_index
      )
    )
  end
end
