defmodule Store.Repo.Migrations.CreatebusinessMember do
  use Ecto.Migration

  def change do
    create table(:members) do
      add(:business_id, references(:businesses), null: false)
      add(:customer_id, references(:customers), null: false)
      timestamps(type: :timestamptz)
    end

    create(
      unique_index(:members, [:business_id, :customer_id],
        name: :members_business_id_customer_id_index
      )
    )
  end
end
