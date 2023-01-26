defmodule Store.Repo.Migrations.ChangeTablesAddCascadingDeletes do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:deleted, :boolean, default: false, null: false)
    end
  end
end
