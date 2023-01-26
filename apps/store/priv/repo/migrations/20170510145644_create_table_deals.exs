defmodule Store.Repo.Migrations.CreateTableDeals do
  use Ecto.Migration

  def change do
    create table(:deals) do
      add(:start_time, :time, null: false)
      add(:end_time, :time, null: false)
      add(:expiry, :timestamptz, null: true)
      add(:is_active, :boolean, null: false)
      add(:business_id, references(:businesses), null: false)
      add(:category_id, references(:categories), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:deals, [:business_id]))
  end
end
