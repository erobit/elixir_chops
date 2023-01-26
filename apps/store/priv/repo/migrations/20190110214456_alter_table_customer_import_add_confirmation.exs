defmodule Store.Repo.Migrations.AlterTableCustomerImportAddConfirmation do
  use Ecto.Migration

  def change do
    alter table(:customer_imports) do
      add(:employee_id, references(:employees))
      add(:confirmation, :boolean)
    end
  end
end
