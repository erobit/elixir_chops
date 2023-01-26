defmodule Store.Repo.Migrations.AlterTableCustomerNotesBodyNullFalse do
  use Ecto.Migration

  def change do
    alter table(:customer_notes) do
      modify(:body, :text, null: true)
    end
  end
end
