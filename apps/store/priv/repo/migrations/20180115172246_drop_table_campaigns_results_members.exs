defmodule Store.Repo.Migrations.DropTableCampaignsResultsMembers do
  use Ecto.Migration

  def change do
    drop(table(:campaigns_results_members))
  end
end
