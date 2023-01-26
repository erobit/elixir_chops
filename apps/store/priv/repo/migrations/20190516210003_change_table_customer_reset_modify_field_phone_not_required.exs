defmodule Store.Repo.Migrations.ChangeTableCustomerResetModifyFieldPhoneNotRequired do
  use Ecto.Migration

  def change do
    alter table(:customer_resets) do
      modify(:phone, :string, null: true)
    end
  end
end
