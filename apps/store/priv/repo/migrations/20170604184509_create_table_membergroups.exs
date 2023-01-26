defmodule Store.Repo.Migrations.CreateTableMemberGroups do
  use Ecto.Migration

  def change do
    create table(:member_groups) do
      add(:name, :string, null: false)
    end

    create(unique_index(:member_groups, [:name]))
  end
end
