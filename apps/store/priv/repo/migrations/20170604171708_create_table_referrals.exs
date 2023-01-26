defmodule Store.Repo.Migrations.CreateTableReferrals do
  use Ecto.Migration

  def change do
    create table(:referrals) do
      add(:recipient_phone, :string, null: true)
      add(:recipient_email, :string, null: true)
      add(:is_completed, :boolean, default: false)
      add(:business_id, references(:businesses), null: false)
      add(:location_id, references(:locations), null: false)
      add(:from_member_id, references(:members), null: false)
      add(:to_member_id, references(:members), null: true)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:referrals, [:location_id, :to_member_id]))
  end
end
