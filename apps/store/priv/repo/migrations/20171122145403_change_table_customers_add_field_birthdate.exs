defmodule Store.Repo.Migrations.ChangeTableCustomersAddFieldBirthdate do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:birthdate, :date, null: true)
    end
  end
end
