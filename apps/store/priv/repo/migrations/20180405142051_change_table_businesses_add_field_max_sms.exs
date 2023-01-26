defmodule Store.Repo.Migrations.ChangeTableBusinessesAddFieldMaxSms do
  use Ecto.Migration

  def change do
    alter table(:businesses) do
      add(:max_sms, :integer, default: 10000)
    end
  end
end
