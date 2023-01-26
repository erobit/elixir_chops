defmodule Store.Repo.Migrations.CreateTableLocationsDeals do
  use Ecto.Migration

  def change do
    create table(:locations_deals, primary_key: false) do
      add(:deal_id, references(:deals), null: false)
      add(:location_id, references(:locations), null: false)
    end

    create(unique_index(:locations_deals, [:deal_id, :location_id]))
  end
end
