defmodule Store.Repo.Migrations.CreateTableMembersCoupons do
  use Ecto.Migration

  def change do
    create table(:members_rewards, primary_key: false) do
      add(:member_id, references(:members), null: false)
      add(:reward_id, references(:rewards), null: false)
      add(:claimed_date, :timestamptz, null: true)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:members_rewards, [:member_id, :reward_id]))
  end
end
