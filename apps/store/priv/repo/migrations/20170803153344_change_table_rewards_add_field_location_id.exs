defmodule Store.Repo.Migrations.ChangeTableRewardsAddFieldLocationId do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      add(:location_id, references(:locations), null: false)
    end

    create(unique_index(:rewards, [:location_id, :type], name: :rewards_location_id_type_index))

    drop(table(:locations_rewards))
  end
end
