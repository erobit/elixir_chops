defmodule Store.Repo.Migrations.CreateTableCustomerNotes do
  use Ecto.Migration

  def change do
    create table(:customer_notes) do
      add(:flagged, :boolean, default: false)
      add(:body, :text, null: false)
      add(:employee_id, references(:employees), null: false)
      add(:customer_id, references(:customers), null: false)
      add(:location_id, references(:locations), null: false)

      timestamps(type: :timestamptz)
    end

    create(index(:customer_notes, [:customer_id, :location_id]))
  end
end
