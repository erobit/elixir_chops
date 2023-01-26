defmodule Store.Repo.Migrations.AlterTableMembershipLocationsAddFieldOptIn do
  use Ecto.Migration

  @update_opted_out_status_from_opt_logs """
  UPDATE membership_locations SET opted_out = true
  WHERE id IN (
    SELECT ml.id FROM membership_locations ml 
    INNER JOIN memberships m ON m.id = ml.membership_id
    INNER JOIN opt_log log ON log.location_id = ml.location_id AND log.customer_id = m.customer_id
    WHERE log.source = 'sms-stop' AND opted_in = false
  );
  """

  def change do
    alter table(:membership_locations) do
      add(:opted_out, :boolean, default: false)
    end

    flush()

    execute(@update_opted_out_status_from_opt_logs)
  end
end
