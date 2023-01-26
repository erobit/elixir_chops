defmodule Store.Repo.Migrations.CreateIndexEmployeePhoneNumber do
  use Ecto.Migration

  def change do
    create(index(:employees, [:phone]))
  end
end
