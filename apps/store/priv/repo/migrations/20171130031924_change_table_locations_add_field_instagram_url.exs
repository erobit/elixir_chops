defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldInstagramUrl do
  use Ecto.Migration

  def up do
    alter table(:locations) do
      add(:instagram_url, :string, null: true)
    end
  end

  def down do
    remove(:instagram_url)
  end
end
