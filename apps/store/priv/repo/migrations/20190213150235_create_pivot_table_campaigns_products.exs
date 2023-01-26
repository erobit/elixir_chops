defmodule Store.Repo.Migrations.CreatePivotTableCampaignsProducts do
  use Ecto.Migration

  def change do
    create table(:campaigns_products, primary_key: false) do
      add(:campaign_id, references(:campaigns))
      add(:product_id, references(:products))
    end

    create(unique_index(:campaigns_products, [:campaign_id, :product_id]))
  end
end
