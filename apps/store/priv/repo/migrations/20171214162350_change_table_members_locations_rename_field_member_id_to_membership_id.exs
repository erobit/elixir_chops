defmodule Store.Repo.Migrations.ChangeTableMembersLocationsRenameFieldMemberIdToMembershipId do
  use Ecto.Migration

  def up do
    Store.Repo.delete_all("members_locations")

    alter table(:members_locations) do
      remove(:member_id)
      add(:membership_id, references(:memberships), null: false)
    end
  end

  def down do
    alter table(:members_locations) do
      remove(:membership_id)
      add(:member_id, references(:memberships), null: false)
    end
  end
end
