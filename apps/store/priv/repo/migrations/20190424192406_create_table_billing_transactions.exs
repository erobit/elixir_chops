defmodule Store.Repo.Migrations.CreateTableBillingTransactions do
  use Ecto.Migration

  def change do
    create table(:billing_transactions) do
      add(:uuid, :uuid, default: fragment("uuid_generate_v4()"))
      add(:profile_id, references(:billing_profiles), null: false)
      add(:card_id, references(:billing_cards), null: true)
      add(:type, :string, null: false)
      add(:status, :string, null: true)
      add(:code, :string, null: true)
      add(:message, :string, null: true)
      add(:amount, :integer, null: true)
      timestamps(type: :timestamptz)
    end

    create(index(:billing_transactions, [:profile_id, :card_id, :type, :status]))
  end
end
