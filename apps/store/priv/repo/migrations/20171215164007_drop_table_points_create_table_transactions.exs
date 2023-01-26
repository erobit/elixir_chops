defmodule Store.Repo.Migrations.DropTablePointsCreateTableTransactions do
  use Ecto.Migration

  def change do
    drop(table(:points))

    flush()

    create table(:transactions) do
      add(:customer_id, references(:customers), null: false)
      add(:location_id, references(:locations), null: false)
      add(:type, :string, null: false)
      add(:units, :integer, null: false)
      add(:meta, :map, null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:transactions, [:customer_id]))
    create(index(:transactions, [:location_id]))
  end
end
