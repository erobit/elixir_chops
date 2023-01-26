defmodule Store.Repo.Migrations.AlterTableProductsAddFieldSyncItemId do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add(:sync_item_id, references(:product_sync_items))
    end
  end
end
