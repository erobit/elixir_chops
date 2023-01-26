defmodule Store.Repo.Migrations.CreateTablePricingTiersAndProductPreferences do
  use Ecto.Migration

  def change do
    create table(:pricing_tiers) do
      add(:business_id, references(:businesses), null: false)
      add(:product_id, references(:products))
      add(:name, :string)
      add(:is_active, :boolean)
      add(:unit_price, :float)
    end

    create table(:pricing_preferences) do
      add(:business_id, references(:businesses), null: false)
      add(:is_basic, :boolean, default: false)
    end

    create(index(:pricing_tiers, [:business_id, :product_id]))

    create(index(:pricing_preferences, [:business_id]))
  end
end
