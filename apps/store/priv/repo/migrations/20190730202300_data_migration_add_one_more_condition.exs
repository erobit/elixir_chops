defmodule Store.Repo.Migrations.DataMigrationAddOneMoreCondition do
  use Ecto.Migration

  def change do
    execute("
      INSERT INTO conditions(id, name, inserted_at, updated_at)
      SELECT 69, 'Other Conditions may Qualify', now(), now() 
    ")
  end
end
