defmodule Store.Repo.Migrations.ChangeTableBusinessesAddFieldCountry do
  use Ecto.Migration

  def change do
    alter table(:businesses) do
      add(:country, :string, null: false, default: "CA")
    end
  end
end
