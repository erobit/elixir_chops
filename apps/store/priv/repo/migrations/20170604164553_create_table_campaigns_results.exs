defmodule Store.Repo.Migrations.CreateTableCampaignsResults do
  use Ecto.Migration

  def change do
    create table(:campaigns_results) do
      add(:message, :string, null: false)
      add(:reach, :integer, null: false, default: 0)
      add(:bounce, :integer, null: false, default: 0)
      add(:clicks, :integer, null: false, default: 0)
      add(:ctr, :integer, null: false, default: 0)
      add(:campaign_id, references(:campaigns), null: false)
      add(:business_id, references(:businesses), null: false)
      timestamps(type: :timestamptz)
    end
  end
end
