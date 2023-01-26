defmodule Store.Repo.Migrations.DropTableMembersRewards do
  use Ecto.Migration

  def change do
    drop(table(:members_rewards))
  end
end
