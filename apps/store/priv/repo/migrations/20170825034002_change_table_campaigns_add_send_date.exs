defmodule Store.Repo.Migrations.ChangeTableCampaignsAddSendDate do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add(:send_date, :timestamptz, null: true)
    end
  end
end
