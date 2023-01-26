defmodule Store.Repo.Migrations.ChangeTableEmployeesDowncaseEmail do
  use Ecto.Migration

  def change do
    execute("UPDATE employees SET email = lower(email)")
  end
end
