defmodule Store.Repo.Migrations.CreateTableCustomerDeals do
  use Ecto.Migration

  def up do
    create table(:customer_deals) do
      add(:name, :string, null: false)
      add(:multiplier, :integer, default: 1, null: false)
      add(:expires, :timestamptz, null: true)
      add(:redeemed, :timestamptz, null: true)
      add(:deal_id, references(:deals), null: false)
      add(:customer_id, references(:customers), null: false)
      add(:location_id, references(:locations), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:customer_deals, [:deal_id]))
    create(index(:customer_deals, [:customer_id]))
    create(index(:customer_deals, [:location_id]))
  end

  def down do
    drop(table(:customer_deals))
  end
end
