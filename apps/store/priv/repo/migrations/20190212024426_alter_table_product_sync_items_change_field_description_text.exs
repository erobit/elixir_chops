defmodule Store.Repo.Migrations.AlterTableProductSyncItemsChangeFieldDescriptionText do
  use Ecto.Migration

  def change do
    alter table(:product_sync_items) do
      modify(:description, :text)
    end
  end
end
