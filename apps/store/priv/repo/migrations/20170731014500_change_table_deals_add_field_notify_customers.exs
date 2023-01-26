defmodule Store.Repo.Migrations.ChangeTableDealsAddFieldNotifyCustomers do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      add(:notify_customers, :boolean)
    end
  end
end
