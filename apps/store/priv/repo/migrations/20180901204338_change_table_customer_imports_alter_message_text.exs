defmodule Store.Repo.Migrations.ChangeTableCustomerImportsAlterMessageText do
  use Ecto.Migration

  def change do
    alter table(:customer_imports) do
      modify(:message, :text, null: true)
    end
  end
end
