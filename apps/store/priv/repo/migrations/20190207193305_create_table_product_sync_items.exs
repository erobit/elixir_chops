defmodule Store.Repo.Migrations.CreateTableProductSyncItems do
  use Ecto.Migration

  def change do
    create table(:product_sync_items) do
      add(:product_integration_id, references(:product_integrations))
      add(:platform_id, :integer)
      add(:source_id, :integer)
      add(:name, :string, null: false)
      add(:description, :string)
      add(:image, :string)
      add(:thumb_image, :string)
      add(:type, :string)
      add(:is_active, :boolean)
      add(:in_stock, :boolean)
      add(:is_imported, :boolean, default: false)
      add(:prices, :map)
      add(:category_id, references(:categories))
      timestamps(type: :timestamptz)
    end

    create(index(:product_sync_items, [:name]))
    create(index(:product_sync_items, [:product_integration_id, :is_imported]))
    create(unique_index(:product_sync_items, [:product_integration_id, :source_id]))
  end
end
