defmodule Store.Repo.Migrations.CreateBusinesses do
  use Ecto.Migration

  def change do
    create table(:businesses) do
      timestamps(type: :timestamptz)
    end
  end
end
