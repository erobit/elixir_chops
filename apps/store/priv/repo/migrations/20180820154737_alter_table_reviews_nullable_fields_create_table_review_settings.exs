defmodule Store.Repo.Migrations.AlterTableReviewsNullableFieldsCreateTableReviewSettings do
  use Ecto.Migration

  def change do
    alter table(:location_reviews) do
      modify(:rating, :integer, null: true)
      add(:completed, :boolean, default: false)
    end

    rename(table(:location_reviews), to: table(:reviews))

    create table(:review_settings) do
      add(:business_id, references(:businesses), null: false)
      add(:enabled, :boolean, default: true)
    end
  end
end
