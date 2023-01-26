defmodule Store.Repo.Migrations.CreateTableCampaignsCustomers do
  use Ecto.Migration

  def change do
    create table(:campaigns_customers, primary_key: false) do
      add(:campaign_id, references(:campaigns), null: false)
      add(:customer_id, references(:customers), null: false)
    end

    create(unique_index(:campaigns_customers, [:campaign_id, :customer_id]))
  end
end
