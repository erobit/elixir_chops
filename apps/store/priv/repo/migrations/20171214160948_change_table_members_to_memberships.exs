defmodule Store.Repo.Migrations.ChangeTableMembersToMemberships do
  use Ecto.Migration

  def up do
    rename(table(:members), to: table(:memberships))
  end

  def down do
    rename(table(:memberships), to: table(:members))
  end
end
