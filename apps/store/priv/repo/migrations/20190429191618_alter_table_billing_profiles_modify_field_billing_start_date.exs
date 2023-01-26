defmodule Store.Repo.Migrations.AlterTableBillingProfilesModifyFieldBillingStartDate do
  use Ecto.Migration

  def change do
    alter table(:billing_profiles) do
      modify(:billing_start, :date, null: true)
    end
  end
end
