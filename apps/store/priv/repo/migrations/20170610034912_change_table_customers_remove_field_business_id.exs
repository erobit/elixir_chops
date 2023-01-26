defmodule Store.Repo.Migrations.ChangeTableCustomersRemoveFieldBusinessId do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      remove(:business_id)
    end

    drop_if_exists(index(:customers, [:business_id]))
  end
end
