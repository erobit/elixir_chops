defmodule Store.Repo.Migrations.CreateTableSmsLog do
  use Ecto.Migration

  def change do
    create table(:sms_log) do
      add(:phone, :string, null: false)
      add(:uuid, :string, null: false)
      add(:entity_id, :integer)
      add(:customer_id, :integer)
      add(:location_id, :integer)
      add(:type, :string, null: false)
      add(:status, :string, null: false)
      add(:message, :string, null: false)
      timestamps()
    end

    create(index(:sms_log, [:uuid]))
  end
end
