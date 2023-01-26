defmodule Store.Repo.Migrations.ChangeTableDealsRemoveFieldMultiplier do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      remove(:multiplier)
    end
  end
end
