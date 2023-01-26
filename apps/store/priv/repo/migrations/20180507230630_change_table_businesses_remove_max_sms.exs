defmodule Store.Repo.Migrations.ChangeTableBusinessesRemoveMaxSms do
  use Ecto.Migration

  def change do
    alter table(:businesses) do
      remove(:max_sms)
    end
  end
end
