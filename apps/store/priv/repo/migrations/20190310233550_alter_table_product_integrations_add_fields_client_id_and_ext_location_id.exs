defmodule Store.Repo.Migrations.AlterTableProductIntegrationsAddFieldsClientIdAndExtLocationId do
  use Ecto.Migration

  def change do
    alter table(:product_integrations) do
      add(:client_id, :integer)
      add(:ext_location_id, :integer)
    end
  end
end
