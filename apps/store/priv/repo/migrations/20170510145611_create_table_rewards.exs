defmodule Store.Repo.Migrations.CreateRewards do
  use Ecto.Migration

  def change do
    create table(:rewards) do
      add(:name, :string, null: false)
      add(:type, :string, null: false)
      add(:points, :integer, null: false)
      add(:is_active, :boolean, null: false, default: false)

      add(:business_id, references(:businesses), null: false)
      add(:category_id, references(:categories), null: false)
      timestamps(type: :timestamptz)
    end
  end
end
