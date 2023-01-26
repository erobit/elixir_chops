defmodule Store.Repo.Migrations.ChangeTableLocationsAddTabletUniqueIndexPerBusiness do
  use Ecto.Migration

  def change do
    create(unique_index(:locations, [:business_id, :tablet]))
  end
end
