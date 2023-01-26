defmodule Store.Repo.Migrations.CreateTableCampaignsResultsClicks do
  use Ecto.Migration

  def change do
    create table(:campaigns_events) do
      add(:campaign_id, references(:campaigns), null: false)
      add(:customer_id, references(:customers), null: false)
      add(:location_id, references(:locations), null: false)
      add(:type, :string, null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:campaigns_events, [:campaign_id]))
    create(index(:campaigns_events, [:customer_id]))
    create(index(:campaigns_events, [:location_id]))
  end
end
