defmodule Store.Repo.Migrations.CreateTableCustomerImports do
  use Ecto.Migration

  def change do
    create table(:customer_imports) do
      add(:location_id, references(:locations), null: false)
      add(:send_sms, :boolean, null: false)
      add(:message, :string, null: true)
      add(:customers, {:array, :string})
      timestamps(type: :timestamptz)
    end
  end
end
