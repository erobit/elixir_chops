defmodule Store.Repo.Migrations.ChangeTableCustomerresetsRemoveFieldCustomerId do
  use Ecto.Migration

  def change do
    alter table(:customer_resets) do
      remove(:customer_id)
    end
  end
end
