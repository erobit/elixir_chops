defmodule Store.Repo.Migrations.CreateTableOptLog do
  use Ecto.Migration

  def change do
    create table(:opt_log) do
      add(:customer_id, references(:customers), null: false)
      add(:location_id, references(:locations), null: false)
      add(:opted_in, :boolean, default: true)
      add(:source, :string)
      timestamps(type: :timestamptz)
    end

    create(index(:opt_log, [:customer_id, :location_id]))
  end
end
