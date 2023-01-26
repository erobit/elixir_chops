defmodule Store.Repo.Migrations.CreateTableBillingPackages do
  use Ecto.Migration

  def change do
    create table(:billing_packages) do
      add(:amount, :decimal, null: false)
      add(:description, :string, null: true)
      timestamps(type: :timestamptz)
    end

    flush()

    execute("INSERT INTO billing_packages(id, amount, description, inserted_at, updated_at) 
             SELECT 1, 199.00, 'Default', now(), now();")
  end
end
