defmodule Store.Repo.Migrations.CreateTableReferralLinks do
  use Ecto.Migration

  def change do
    create table(:referral_links) do
      add(:location_id, references(:locations), null: false)
      add(:customer_id, references(:customers), null: false)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:referral_links, [:customer_id, :location_id]))
  end
end
