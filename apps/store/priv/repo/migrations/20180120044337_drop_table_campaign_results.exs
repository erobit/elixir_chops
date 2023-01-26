defmodule Store.Repo.Migrations.DropTableCampaignResults do
  use Ecto.Migration

  def change do
    drop(table(:campaigns_results))
  end
end
