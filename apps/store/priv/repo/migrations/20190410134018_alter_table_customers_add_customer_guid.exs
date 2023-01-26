defmodule Store.Repo.Migrations.AlterTableCustomersAddCustomerGuid do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:qr_code, :binary_id)
    end

    create(unique_index(:customers, [:qr_code]))

    flush()

    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
    execute("UPDATE customers SET qr_code=uuid_generate_v4();")

    alter table(:customers) do
      modify(:qr_code, :binary_id, null: false)
    end
  end
end
