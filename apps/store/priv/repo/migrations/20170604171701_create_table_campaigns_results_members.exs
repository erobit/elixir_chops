defmodule Store.Repo.Migrations.CreateTableCampaignsResultsMembers do
  use Ecto.Migration

  def change do
    create table(:campaigns_results_members, primary_key: false) do
      add(:campaigns_results_id, references(:campaigns_results), null: false)
      add(:member_id, references(:members), null: false)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:campaigns_results_members, [:campaigns_results_id, :member_id]))
  end
end
