defmodule Store.Repo.Migrations.CreateTableProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add(:name, :string, null: false)
      add(:description, :text)
      add(:image, :string)
      add(:type, :string)
      add(:is_active, :boolean, default: true)
      add(:business_id, references(:businesses), null: false)
      add(:category_id, references(:categories), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:products, [:business_id]))

    flush()

    create table(:product_locations) do
      add(:product_id, references(:products), null: false)
      add(:location_id, references(:locations), null: false)
    end
  end
end
