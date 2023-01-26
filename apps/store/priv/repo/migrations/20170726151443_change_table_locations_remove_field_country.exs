defmodule Store.Repo.Migrations.ChangeTableLocationsRemoveFieldCountry do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      remove(:country)
    end
  end
end
