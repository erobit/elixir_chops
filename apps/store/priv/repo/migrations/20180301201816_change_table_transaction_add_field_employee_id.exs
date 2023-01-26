defmodule Store.Repo.Migrations.ChangeTableTransactionAddFieldEmployeeId do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:employee_id, references(:employees), null: true)
    end
  end
end
