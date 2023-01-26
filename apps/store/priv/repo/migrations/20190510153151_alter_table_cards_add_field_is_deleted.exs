defmodule Store.Repo.Migrations.AlterTableCardsAddFieldIsDeleted do
  use Ecto.Migration

  def change do
    alter table(:billing_cards) do
      add(:is_deleted, :boolean, default: false, null: false)
    end
  end
end
