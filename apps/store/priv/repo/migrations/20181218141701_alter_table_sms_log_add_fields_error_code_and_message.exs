defmodule Store.Repo.Migrations.AlterTableSmsLogAddFieldsErrorCodeAndMessage do
  use Ecto.Migration

  def change do
    alter table(:sms_log) do
      add(:error_code, :integer)
      add(:error_message, :string)
    end
  end
end
