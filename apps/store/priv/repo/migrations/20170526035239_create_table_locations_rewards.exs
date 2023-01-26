defmodule Store.Repo.Migrations.CreateTableLocationsRewards do
  use Ecto.Migration

  def change do
    create table(:locations_rewards, primary_key: false) do
      add(:location_id, references(:locations), null: false)
      add(:reward_id, references(:rewards), null: false)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:locations_rewards, [:location_id, :reward_id]))
  end
end
