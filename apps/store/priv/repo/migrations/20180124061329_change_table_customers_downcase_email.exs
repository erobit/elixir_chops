defmodule Store.Repo.Migrations.ChangeTableCustomersDowncaseEmail do
  use Ecto.Migration

  def change do
    execute("UPDATE customers SET email = lower(email)")
  end
end
