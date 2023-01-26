defmodule Store.Repo.Migrations.AlterTableCampaignsResultsRemoveCtrAndClicks do
  use Ecto.Migration

  def change do
    alter table(:campaigns_results) do
      remove(:ctr)
      remove(:clicks)
    end
  end
end
