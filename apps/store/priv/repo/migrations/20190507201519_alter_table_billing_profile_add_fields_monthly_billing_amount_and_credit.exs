defmodule Store.Repo.Migrations.AlterTableBillingProfileAddFieldsMonthlyBillingAmountAndCredit do
  use Ecto.Migration

  def change do
    alter table(:billing_profiles) do
      add(:billing_amount, :decimal, default: 199, null: false)
      add(:billing_credit, :decimal, default: 0, null: false)
    end
  end
end
