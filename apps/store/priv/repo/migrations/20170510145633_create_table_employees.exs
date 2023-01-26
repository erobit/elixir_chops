defmodule Store.Repo.Migrations.CreateTableEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add(:name, :string, null: false)
      add(:email, :string, null: false)
      add(:phone, :string)
      add(:role, :string, null: false)
      add(:is_active, :boolean, null: false)
      add(:business_id, references(:businesses), null: false)
      timestamps(type: :timestamptz)
    end

    create(unique_index(:employees, [:email]))
    create(index(:employees, [:business_id]))
  end
end
