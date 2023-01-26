defmodule Store.Repo.Migrations.CreateTableMembersDeals do
  use Ecto.Migration

  def change do
    create table(:members_deals, primary_key: false) do
      add(:member_id, references(:members), null: false)
      add(:deal_id, references(:rewards), null: false)
      add(:claimed_date, :timestamptz, null: true)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:members_deals, [:member_id, :deal_id]))
  end
end
