defmodule Store.Repo.Migrations.ChangeTableSmsSettingsModifyPhoneNumberDefaultNil do
  use Ecto.Migration

  def change do
    alter table(:sms_settings) do
      modify(:phone_number, :string, null: true, default: nil)
    end
  end
end
