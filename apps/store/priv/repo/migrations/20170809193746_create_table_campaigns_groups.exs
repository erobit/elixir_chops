defmodule Store.Repo.Migrations.CreateTableCampaignsGroups do
  use Ecto.Migration

  def change do
    create table(:campaigns_groups, primary_key: false) do
      add(:campaign_id, references(:campaigns), null: false)
      add(:member_group_id, references(:member_groups), null: false)
    end

    create(unique_index(:campaigns_groups, [:campaign_id, :member_group_id]))
  end
end
