defmodule Store.Repo.Migrations.CreateTableProductIntegrations do
  use Ecto.Migration

  def change do
    create table(:product_integrations) do
      add(:location_id, references(:locations))
      add(:name, :string)
      add(:api_key, :string)
      add(:is_active, :boolean)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:product_integrations, [:location_id, :name]))
    create(index(:product_integrations, [:location_id]))
  end
end
