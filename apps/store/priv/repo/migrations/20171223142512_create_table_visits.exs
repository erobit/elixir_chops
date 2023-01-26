defmodule Store.Repo.Migrations.CreateTableVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add(:customer_id, references(:customers), null: false)
      add(:location_id, references(:locations), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:visits, [:customer_id]))
    create(index(:visits, [:location_id]))
  end
end
