defmodule Store.Repo.Migrations.ChangeTableDealsRemoveFieldNotifyCustomers do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      remove(:notify_customers)
    end
  end
end
