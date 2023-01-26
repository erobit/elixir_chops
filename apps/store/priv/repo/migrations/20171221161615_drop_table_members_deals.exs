defmodule Store.Repo.Migrations.DropTableMembersDeals do
  use Ecto.Migration

  def change do
    drop(table(:members_deals))
  end
end
