defmodule Store.Repo.Migrations.ChangeTableCampaignAddFieldDealId do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add(:deal_id, references(:deals))
    end
  end
end
