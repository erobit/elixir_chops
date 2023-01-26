defmodule Store.Repo.Migrations.DataMigrationAddBillingProfiles do
  use Ecto.Migration

  def up do
    execute("INSERT INTO billing_profiles(location_id, payment_type, inserted_at, updated_at) 
             SELECT id, 'credit_card', now(), now() FROM locations;")
  end

  def down do
    execute("DELETE FROM billing_profiles;")
  end
end
