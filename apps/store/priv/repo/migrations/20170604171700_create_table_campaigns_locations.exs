defmodule Store.Repo.Migrations.CreateTableCampaignsLocations do
  use Ecto.Migration

  def change do
    create table(:campaigns_locations, primary_key: false) do
      add(:campaign_id, references(:campaigns), null: false)
      add(:location_id, references(:locations), null: false)
    end

    create(unique_index(:campaigns_locations, [:campaign_id, :location_id]))
  end
end
