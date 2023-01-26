defmodule Store.Repo.Migrations.CreateTableCustomerProducts do
  use Ecto.Migration

  def change do
    create table(:customer_products) do
      add(:customer_id, references(:customers))
      add(:product_id, references(:products))
      add(:is_active, :boolean, default: true)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:customer_products, [:customer_id, :product_id]))
    create(index(:customer_products, [:customer_id]))
  end
end
