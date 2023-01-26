defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldName do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      add(:name, :string, null: true)
    end
  end

  def down do
    alter table(:customers) do
      remove(:name)
    end
  end
end
