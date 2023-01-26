defmodule Store.Repo.Migrations.ChangeTableCustomerResetAddFieldEmail do
  use Ecto.Migration

  def change do
    alter table(:customer_resets) do
      add(:email, :string, null: true, default: nil)
    end
  end
end
