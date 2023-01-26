defmodule Store.Repo.Migrations.ChangeTableCustomersAlterNullableFields do
  use Ecto.Migration

  def up do
    alter table(:customers) do
      modify(:email, :string, null: true)
      remove(:birthdate)
    end

    flush()

    alter table(:customers) do
      add(:birthdate, :date, null: true)
    end

    flush()

    Store.Repo.update_all("customers", set: [birthdate: ~D[1969-01-01]])

    alter table(:customers) do
      modify(:birthdate, :date, null: false)
    end
  end

  def down do
    alter table(:customers) do
      modify(:email, :string, null: false)
      modify(:birthdate, :date, null: true)
    end
  end
end
