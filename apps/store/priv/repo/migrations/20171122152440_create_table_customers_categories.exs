defmodule Store.Repo.Migrations.CreateTableCustomersCategories do
  use Ecto.Migration

  def up do
    create table(:customers_categories, primary_key: false) do
      add(:customer_id, references(:customers), null: false)
      add(:category_id, references(:categories), null: false)
    end

    create(unique_index(:customers_categories, [:customer_id, :category_id]))
  end

  def down do
    drop(table(:customers_categories))
  end
end
