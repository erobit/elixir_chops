defmodule Store.Repo.Migrations.CreateTableCustomerRewards do
  use Ecto.Migration

  def up do
    create table(:customer_rewards) do
      add(:name, :string, null: false)
      add(:type, :string, null: false)

      add(:expires, :timestamptz, null: true)
      add(:redeemed, :timestamptz, null: true)
      add(:reward_id, references(:rewards), null: false)
      add(:customer_id, references(:customers), null: false)
      add(:location_id, references(:locations), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:customer_rewards, [:reward_id]))
    create(index(:customer_rewards, [:customer_id]))
    create(index(:customer_rewards, [:location_id]))
  end

  def down do
    drop(table(:customer_rewards))
  end
end
