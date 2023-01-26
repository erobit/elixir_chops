defmodule Store.Repo.Migrations.CreateTableSmsSettings do
  use Ecto.Migration

  def change do
    create table(:sms_settings) do
      add(:business_id, references(:businesses), null: false)
      add(:provider, :string, null: false)
      add(:phone_number, :string, null: false, default: "18886031965")
      add(:max_sms, :integer, default: 10000)
      timestamps(type: :timestamptz)
    end

    create(index(:sms_settings, [:business_id]))

    flush()

    # create a new record for every business and copy over the max_sms values
    execute("INSERT INTO sms_settings(business_id, provider, max_sms, inserted_at, updated_at)
      SELECT id, 'plivo', max_sms, now(), now() FROM businesses;")
  end
end
