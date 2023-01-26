defmodule Store.Repo.Migrations.SimulateData do
  use Ecto.Migration

  def up do
    # Note: used SELECT pg_catalog.pg_get_functiondef('simulate'::regproc) to export the function
    # in a format that will work with the execute function below
    file_path = Path.join(Application.app_dir(:store, "priv"), "repo/simulate_data.sql")
    {:ok, query} = File.read(file_path)
    execute(query)
  end

  def down do
    execute("DROP FUNCTION simulate")
  end
end
