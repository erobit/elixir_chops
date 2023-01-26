defmodule Store.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add(:phone, :string, null: false)
      add(:email, :string, null: false)
      add(:business_id, references(:businesses), null: false)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:customers, [:phone]))
    create(unique_index(:customers, [:email]))
    create(index(:customers, [:business_id]))
  end
end
