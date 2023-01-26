defmodule Store.Repo.Migrations.CreateTableBillingCards do
  use Ecto.Migration

  def change do
    create table(:billing_cards) do
      add(:card_id, :string, null: false)
      add(:profile_id, references(:billing_profiles), null: false)
      add(:payment_token, :string, null: true)
      add(:type, :string, null: true)
      add(:category, :string, null: false)
      add(:expiry_month, :integer, null: false)
      add(:expiry_year, :integer, null: false)
      add(:last_digits, :string, null: false)
      add(:status, :string, null: true)
      add(:is_default, :boolean, null: false, default: true)
      add(:nickname, :string, null: true)
      add(:holdername, :string, null: true)
      add(:bin, :string, null: true)
      add(:billing_address_id, :string, null: true)
      timestamps(type: :timestamptz)
    end

    create(index(:billing_cards, [:card_id, :profile_id]))
  end
end
