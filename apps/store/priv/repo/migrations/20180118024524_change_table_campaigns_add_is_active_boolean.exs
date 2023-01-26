defmodule Store.Repo.Migrations.ChangeTableCampaignsAddIsActiveBoolean do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add(:is_active, :boolean, default: true)
    end
  end
end
