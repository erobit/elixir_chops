defmodule Store.Repo.Migrations.ChangeTableLocationsAddFieldsPhoneAndEmailConfirm do
  use Ecto.Migration

  def up do
    alter table(:locations) do
      add(:phone_confirmed, :boolean, default: false)
      add(:email_confirmed, :boolean, default: false)
    end
  end

  def down do
    alter table(:locations) do
      remove(:phone_confirmed)
      remove(:email_confirmed)
    end
  end
end
