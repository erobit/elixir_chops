defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldTablet do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:tablet, :string)
    end
  end
end
