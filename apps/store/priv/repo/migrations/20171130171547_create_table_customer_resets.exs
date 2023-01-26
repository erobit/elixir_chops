defmodule Store.Repo.Migrations.CreateTableCustomerResets do
  use Ecto.Migration

  def up do
    create table(:customer_resets) do
      add(:phone, :string, null: false)
      add(:code, :string)
      add(:expires, :timestamptz, null: false)
      add(:sent, :boolean, null: false, default: false)
      add(:received, :boolean, null: false, default: false)
      add(:used, :boolean, null: false, default: false)
      add(:customer_id, references(:customers), null: false)
      timestamps(type: :timestamptz)
    end
  end

  def down do
    drop(table(:customer_resets))
  end
end
