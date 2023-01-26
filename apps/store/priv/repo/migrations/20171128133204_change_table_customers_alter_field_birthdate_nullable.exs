defmodule Store.Repo.Migrations.ChangeTableCustomersAlterFieldBirthdateNullable do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      remove(:birthdate)
      add(:birthdate, :date, null: true)
    end

    flush()

    Store.Repo.update_all("customers", set: [birthdate: nil])
  end

  def down do
    alter table(:customers) do
      modify(:birthdate, :date, null: false)
    end
  end
end
