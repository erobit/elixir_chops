defmodule Store.Repo.Migrations.ChangeTableDealsAddFieldName do
  use Ecto.Migration

  def change do
    alter table(:deals) do
      add(:name, :string)
    end
  end
end
