defmodule Store.Repo.Migrations.AlterTableCategoriesRemoveFieldBusinessId do
  use Ecto.Migration

  def change do
    drop(index(:categories, [:business_id]))

    alter table(:categories) do
      remove(:business_id)
    end
  end
end
