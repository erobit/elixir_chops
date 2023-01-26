defmodule Store.Repo.Migrations.DataMigrationLogVisitsWhereStampsWereEarned do
  use Ecto.Migration

  def change do
    execute(
      "INSERT INTO visits(customer_id, location_id, inserted_at, updated_at, point)
    SELECT DISTINCT customer_id, location_id, date_trunc('day', transactions.inserted_at) as inserted_at, now() as updated_at, null as point FROM transactions
    where customer_id not in (select customer_id from visits where customer_id = transactions.customer_id and location_id = transactions.location_id and date_trunc('day', inserted_at) = date_trunc('day', transactions.inserted_at)) and type = 'credit' ORDER by customer_id;"
    )
  end
end
