defmodule Store.Repo.Migrations.ChangeTableCustomerDealsRemoveFieldMultiplier do
  use Ecto.Migration

  def change do
    alter table(:customer_deals) do
      remove(:multiplier)
    end
  end
end
