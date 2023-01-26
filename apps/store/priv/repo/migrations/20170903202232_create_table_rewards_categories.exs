defmodule Store.Repo.Migrations.CreateTableRewardsCategories do
  use Ecto.Migration

  def change do
    create table(:rewards_categories, primary_key: false) do
      add(:reward_id, references(:rewards), null: false)
      add(:category_id, references(:categories), null: false)
    end

    create(unique_index(:rewards_categories, [:reward_id, :category_id]))
  end
end
