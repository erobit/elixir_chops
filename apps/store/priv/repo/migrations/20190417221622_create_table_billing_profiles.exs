defmodule Store.Repo.Migrations.CreateTableBillingSettings do
  use Ecto.Migration

  def change do
    create table(:billing_profiles) do
      add(:location_id, references(:locations), null: false)
      add(:profile_id, :string, null: true)
      add(:locale, :string, default: "en_US")
      add(:payment_token, :string)

      add(:first_name, :string, null: true)
      add(:middle_name, :string, null: true)
      add(:last_name, :string, null: true)
      add(:birth_date, :date, null: true)
      add(:email, :string, null: true)
      add(:phone, :string, null: true)
      add(:ip, :string, null: true)
      add(:gender, :string, null: true)
      add(:nationality, :string, null: true)
      add(:cell_phone, :string, null: true)

      add(:payment_type, :string, null: true)
      add(:billing_start, :timestamptz, null: true)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:billing_profiles, [:location_id]))
    create(index(:billing_profiles, [:profile_id]))
  end
end
