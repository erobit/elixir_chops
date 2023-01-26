defmodule Store.Repo.Migrations.ChangeTableSmsLogDateTimestamptz do
  use Ecto.Migration

  def change do
    alter table(:sms_log) do
      modify(:inserted_at, :timestamptz)
      modify(:updated_at, :timestamptz)
    end
  end
end
