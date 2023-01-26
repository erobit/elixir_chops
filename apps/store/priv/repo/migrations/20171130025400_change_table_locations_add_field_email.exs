defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldEmail do
  use Ecto.Migration

  def up do
    alter table(:locations) do
      add(:email, :string, null: true)
    end
  end

  def down do
    remove(:email)
  end
end
