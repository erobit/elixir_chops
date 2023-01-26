defmodule Store.Repo.Migrations.CreateTablePoints do
  use Ecto.Migration

  def change do
    create table(:points) do
      add(:type, :string, null: false)
      add(:amount, :integer, null: false)
      add(:member_id, references(:members), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:points, [:member_id]))
  end
end
