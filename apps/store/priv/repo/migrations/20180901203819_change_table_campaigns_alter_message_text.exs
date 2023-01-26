defmodule Store.Repo.Migrations.ChangeTableCampaignsAlterMessageText do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      modify(:message, :text, null: false)
    end
  end
end
