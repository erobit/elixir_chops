defmodule Store.Repo.Migrations.ChangeTableSmsSettingsAddFieldDistributedUuid do
  use Ecto.Migration

  def change do
    alter table(:sms_settings) do
      add(:distributed_uuid, :string, default: "")
    end
  end
end
