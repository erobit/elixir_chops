defmodule Store.Repo.Migrations.UpdateCustomersAddGender do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:gender, :string)
    end
  end
end
