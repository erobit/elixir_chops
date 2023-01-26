defmodule Store.Repo.Migrations.ChangeTableRewardsRemoveCategoryId do
  use Ecto.Migration

  def change do
    alter table(:rewards) do
      remove(:category_id)
    end
  end
end
