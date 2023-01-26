defmodule Store.Repo.Migrations.ChangeTableBusinessesAddNameAndSubdomain do
  use Ecto.Migration

  def change do
    alter table(:businesses) do
      add(:name, :string)
      add(:subdomain, :string)
    end

    create(unique_index(:businesses, [:subdomain]))
  end
end
