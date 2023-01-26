defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldIsActive do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:is_active, :boolean)
    end
  end
end
