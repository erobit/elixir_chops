defmodule Store.Repo.Migrations.ChangeTableCampaignsAddSchedulingBooleans do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add(:send_now, :boolean, default: false)
      add(:scheduled, :boolean, default: false)
      add(:sent, :boolean, default: false)
    end
  end
end
