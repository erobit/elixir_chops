defmodule Store.Repo.Migrations.CreateTableMembersCategories do
  use Ecto.Migration

  def change do
    create table(:members_categories, primary_key: false) do
      add(:member_id, references(:members), null: false)
      add(:category_id, references(:categories), null: false)
    end

    create(unique_index(:members_categories, [:member_id, :category_id]))
  end
end
