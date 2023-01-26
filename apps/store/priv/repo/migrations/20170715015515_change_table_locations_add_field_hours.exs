defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldHours do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:hours, {:array, :map}, required: true, default: [])
    end
  end
end
