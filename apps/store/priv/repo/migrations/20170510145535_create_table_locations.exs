defmodule Store.Repo.Migrations.CreatebusinessLocation do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add(:name, :string, null: false)
      add(:address, :string, null: false)
      add(:country, :string, null: false)
      add(:city, :string, null: false)
      add(:province, :string, null: false)
      add(:postal_code, :string, null: false)
      add(:phone, :string, null: false)
      add(:website_url, :string)
      add(:facebook_url, :string)
      add(:about, :string)
      add(:portrait_image, :string, null: false)
      add(:landscape_image, :string, null: false)

      add(:business_id, references(:businesses), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:locations, [:business_id]))
  end
end
