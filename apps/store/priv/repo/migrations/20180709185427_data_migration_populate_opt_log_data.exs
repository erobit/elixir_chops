defmodule Store.Repo.Migrations.DataMigrationPopulateOptLogData do
  use Ecto.Migration
  use Store.Model

  @insert_opt_logs """
  INSERT INTO opt_log (customer_id, location_id, opted_in, source)
  SELECT m.customer_id, ml.location_id, ml.notifications_enabled, CASE WHEN ml.notifications_enabled = true THEN 'join' ELSE 'toggle' END
  FROM membership_locations ml
  INNER JOIN memberships m ON m.id = ml.membership_id;
  """

  def change do
    execute(@insert_opt_logs)
  end
end
