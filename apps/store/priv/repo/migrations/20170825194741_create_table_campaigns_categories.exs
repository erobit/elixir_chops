defmodule Store.Repo.Migrations.CreateTableCampaignsCategories do
  use Ecto.Migration

  def change do
    create table(:campaigns_categories, primary_key: false) do
      add(:campaign_id, references(:campaigns), null: false)
      add(:category_id, references(:categories), null: false)
    end

    create(unique_index(:campaigns_categories, [:campaign_id, :category_id]))
  end
end
