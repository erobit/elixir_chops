defmodule Store.Repo.Migrations.AlterTableSmsSettingsAddFieldLocationId do
  use Ecto.Migration

  @create_settings_per_location """
  INSERT INTO sms_settings(
    original_sms_id,
    business_id,
    location_id,
    provider,
    phone_number,
    max_sms,
    send_distributed,
    distributed_uuid,
    inserted_at,
    updated_at
  )
  SELECT
    s.id,
    s.business_id,
    l.id as "location_id",
    s.provider,
    s.phone_number,
    s.max_sms,
    s.send_distributed,
    s.distributed_uuid,
    s.inserted_at,
    s.updated_at
  FROM sms_settings s
    INNER JOIN locations l ON l.business_id = s.business_id;
  """

  @delete_original_sms_settings """
  DELETE FROM sms_settings WHERE id IN (SELECT DISTINCT original_sms_id FROM sms_settings);
  """

  def change do
    alter table(:sms_settings) do
      add(:location_id, references(:locations))
      add(:original_sms_id, :integer)
    end

    flush()

    execute(@create_settings_per_location)
    execute(@delete_original_sms_settings)

    alter table(:sms_settings) do
      remove(:business_id)
      remove(:original_sms_id)
    end

    create(index(:sms_settings, [:location_id]))

    flush()
  end
end
