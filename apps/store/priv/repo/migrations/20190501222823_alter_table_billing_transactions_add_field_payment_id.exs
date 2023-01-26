defmodule Store.Repo.Migrations.AlterTableBillingTransactionsAddFieldPaymentId do
  use Ecto.Migration

  def change do
    alter table(:billing_transactions) do
      add(:payment_id, :string, null: true)
    end
  end
end
