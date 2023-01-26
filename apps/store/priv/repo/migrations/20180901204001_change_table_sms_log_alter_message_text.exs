defmodule Store.Repo.Migrations.ChangeTableSmsLogAlterMessageText do
  use Ecto.Migration

  def change do
    alter table(:sms_log) do
      modify(:message, :text, null: false)
    end
  end
end
