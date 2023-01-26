defmodule Store.Repo.Migrations.ChangeTablePointsTweakFields do
  use Ecto.Migration

  def change do
    alter table(:points, primary_key: false) do
      add(:membership_location_id, references(:membership_locations),
        null: false,
        primary_key: true
      )

      add(:units, :integer, default: 0)
      remove(:membership_id)
      remove(:amount)
      remove(:id)
    end
  end
end
