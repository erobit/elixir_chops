defmodule Store.Repo.Migrations.AlterTableBusinessesAddFieldIsActive do
  use Ecto.Migration

  def change do
    alter table(:businesses) do
      add(:is_active, :boolean, null: false, default: true)
    end
  end
end
