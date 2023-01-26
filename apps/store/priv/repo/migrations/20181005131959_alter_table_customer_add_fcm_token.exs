defmodule Store.Repo.Migrations.AlterTableCustomerAddFcmToken do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:fcm_token, :string)
    end
  end
end
