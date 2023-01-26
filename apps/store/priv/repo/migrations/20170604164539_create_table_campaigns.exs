defmodule Store.Repo.Migrations.CreateTableCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns) do
      add(:message, :string, null: false)
      add(:business_id, references(:businesses), null: false)
      timestamps(type: :timestamptz)
    end
  end
end
