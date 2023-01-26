defmodule Store.Repo.Migrations.ChangeTableSmsSettingsAddPlivoPowerpack do
  use Ecto.Migration

  def change do
    alter table(:sms_settings) do
      add(:send_distributed, :boolean, default: false)
    end
  end
end
