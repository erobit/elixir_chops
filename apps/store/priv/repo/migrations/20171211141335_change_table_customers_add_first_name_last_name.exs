defmodule Store.Repo.Migrations.ChangeTableCustomersAddFirstNameLastName do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      add(:first_name, :string)
      add(:last_name, :string)
      remove(:name)
    end
  end

  def down do
    alter table(:customers) do
      remove(:first_name)
      remove(:last_name)
      add(:name, :string)
    end
  end
end
