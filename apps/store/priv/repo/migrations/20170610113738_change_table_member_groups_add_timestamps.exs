defmodule Store.Repo.Migrations.ChangeTableMemberGroupsAddTimestamps do
  use Ecto.Migration

  def change do
    alter table(:member_groups) do
      timestamps(type: :timestamptz)
    end
  end
end
