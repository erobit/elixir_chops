defmodule Store.Repo.Migrations.ChangeTableLocationsAddQrCodeField do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add(:qr_code, :binary_id, null: false)
    end
  end
end
