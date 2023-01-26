defmodule Store.Repo.Migrations.ChangeTableBusinessesAddFieldType do
  use Ecto.Migration

  def change do
    alter table(:businesses) do
      add(:type, :string)
    end
  end
end
