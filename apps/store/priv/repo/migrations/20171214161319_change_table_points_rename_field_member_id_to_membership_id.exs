defmodule Store.Repo.Migrations.ChangeTablePointsRenameFieldMemberIdToMembershipId do
  use Ecto.Migration

  def up do
    alter table(:points) do
      remove(:member_id)
      add(:membership_id, references(:memberships), null: false)
    end
  end

  def down do
    alter table(:points) do
      remove(:membership_id)
      add(:member_id, references(:memberships), null: false)
    end
  end
end
