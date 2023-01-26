defmodule Store.Repo.Migrations.ChangeTableLocationsRemoveFieldPortraitImage do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      remove(:portrait_image)
    end
  end
end
