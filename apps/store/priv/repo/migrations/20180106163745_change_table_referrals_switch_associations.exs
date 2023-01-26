defmodule Store.Repo.Migrations.ChangeTableReferralsSwitchAssociations do
  use Ecto.Migration

  def change do
    drop(table(:referrals))

    flush()

    create table(:referrals) do
      add(:recipient_phone, :string, null: true)
      add(:is_completed, :boolean, default: false)
      add(:business_id, references(:businesses), null: false)
      add(:location_id, references(:locations), null: false)
      add(:from_customer_id, references(:customers), null: false)
      add(:to_customer_id, references(:customers), null: true)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:referrals, [:location_id, :from_customer_id]))
  end
end
