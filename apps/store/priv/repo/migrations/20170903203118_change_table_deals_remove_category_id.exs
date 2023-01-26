defmodule Store.Repo.Migrations.ChangeTableDealsRemoveCategoryId do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      remove(:category_id)
    end
  end
end
