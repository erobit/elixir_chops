defmodule Store.Repo.Migrations.ChangeTableEmployeesRemoveFieldName do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      remove(:name)
    end
  end
end
