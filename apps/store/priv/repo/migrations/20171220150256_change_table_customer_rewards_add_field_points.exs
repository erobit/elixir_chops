defmodule Store.Repo.Migrations.ChangeTableCustomerRewardsAddFieldPoints do
  use Ecto.Migration

  def up do
    alter table(:customer_rewards) do
      add(:points, :integer, null: false)
    end
  end

  def down do
    alter table(:customer_rewards) do
      remove(:points)
    end
  end
end
