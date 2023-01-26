defmodule Store.Repo.Migrations.CreateTableDealsCategories do
  use Ecto.Migration

  def change do
    create table(:deals_categories, primary_key: false) do
      add(:deal_id, references(:deals), null: false)
      add(:category_id, references(:categories), null: false)
    end

    create(unique_index(:deals_categories, [:deal_id, :category_id]))
  end
end
