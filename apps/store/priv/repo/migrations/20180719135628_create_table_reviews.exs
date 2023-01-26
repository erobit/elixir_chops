defmodule Store.Repo.Migrations.CreateTableReviews do
  use Ecto.Migration

  def change do
    create table(:location_reviews) do
      add(:content, :string)
      add(:rating, :integer, null: false)
      add(:location_id, references(:locations), null: false)
      add(:customer_id, references(:customers), null: false)
      timestamps(type: :timestamptz)
    end

    create(index(:location_reviews, [:location_id]))

    create(
      unique_index(:location_reviews, [:customer_id, :location_id],
        name: :location_review_customer_location_index
      )
    )
  end
end
