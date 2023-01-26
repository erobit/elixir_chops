defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldCountry do
  use Ecto.Migration

  def up do
    alter table(:locations) do
      add(:country, :string, required: true, default: "")
    end
  end

  def down do
    alter table(:locations) do
      remove(:country)
    end
  end
end
