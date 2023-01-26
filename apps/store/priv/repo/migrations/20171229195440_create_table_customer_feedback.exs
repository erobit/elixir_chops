defmodule Store.Repo.Migrations.CreateTableCustomerFeedback do
  use Ecto.Migration

  def change do
    create table(:customer_feedback) do
      add(:feedback, :string, null: false)
      add(:customer_id, references(:customers), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:customer_feedback, [:customer_id]))
  end
end
