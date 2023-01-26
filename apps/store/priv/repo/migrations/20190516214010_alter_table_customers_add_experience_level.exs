defmodule Store.Repo.Migrations.AlterTableCustomersAddExperienceLevel do
  use Ecto.Migration

  def change do
    alter table(:customers) do
      add(:experience_level, :string)
    end
  end
end
