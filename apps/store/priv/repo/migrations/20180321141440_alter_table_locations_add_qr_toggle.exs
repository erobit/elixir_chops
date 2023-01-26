defmodule Store.Repo.Migrations.AlterTableLocationsAddQrToggle do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:qr_budtender_scanning, :boolean, default: true)
    end

    flush()

    # Prevent existing locations functionality changing.
    execute("UPDATE locations SET qr_budtender_scanning=false;")
  end
end
