defmodule Store.Repo.Migrations.CreateTableCategory do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add(:name, :string, null: false)
      add(:business_id, references(:businesses), null: true)
      timestamps(type: :timestamptz)
    end

    create(index(:categories, [:business_id]))
  end
end
