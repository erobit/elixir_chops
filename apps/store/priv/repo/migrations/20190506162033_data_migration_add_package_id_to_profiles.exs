defmodule Store.Repo.Migrations.DataMigrationAddPackageIdToProfiles do
  use Ecto.Migration

  def change do
    execute("UPDATE billing_profiles SET package_id = 1;")
  end
end
